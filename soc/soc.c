#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <fcntl.h>
#include <signal.h>
#include <sys/mman.h>
#include "hps_0.h"

// MEMORY MAP defines
#define H2F_AXI_LW_BASE_ADDR 0xFF200000
#define H2F_AXI_LW_SPAN      0x00200000
#define H2F_AXI_FB_BASE_ADDR 0xC0000000
#define H2F_AXI_FB_SPAN      0x3C000000
#define FPGA_MEM_BASE        0x30000000
#define FPGA_MEM_SPAN        0x10000000  // 256 MiB

void *lw_base;
void *fb_base;
void *fpga_base;

#define HPS_REG_OFFSET    0x00000000
#define FPGA_REG_OFFSET   0x00000010
#define SYSTEM_IN_OFFSET  0x00000000
#define SYSTEM_OUT_OFFSET 0x08000000

uint8_t  *hps_reg;
uint8_t  *fpga_reg;
uint32_t *system_in;
uint32_t *system_out;

int fd;

void handler(int signo){
    *hps_reg = 0;
    munmap(lw_base, H2F_AXI_LW_SPAN);
    munmap(fb_base, H2F_AXI_FB_SPAN);
    munmap(fpga_base, FPGA_MEM_SPAN);
    close(fd);
    exit(0);
}

#define SET_FLAG 0
#define CLEAR_FLAG 1
#define TOGGLE_FLAG 2

typedef enum 
{
    HPS_ACTIVE,
    HPS_RESETN,
    HPS_SENT,
    HPS_RECEIVED
} HPS_flags;

typedef enum 
{
    FPGA_IDLE,
    FPGA_ACTIVE,
    FPGA_RECEIVED,
    FPGA_DONE
} FPGA_flags;

void set_flag(HPS_flags flag, uint8_t mode) {

    if (hps_reg == NULL) return;
    
    switch (mode) {
        case SET_FLAG:
            *hps_reg = *hps_reg | (1 << flag);
            break;
        case CLEAR_FLAG: 
            *hps_reg = *hps_reg & ~(1 << flag);
            break;
        case TOGGLE_FLAG:
            *hps_reg = *hps_reg ^ (1 << flag);
            break;
        default:
            break;
    }
}

uint8_t get_flag(FPGA_flags flag) {
    if (fpga_reg == NULL) return 0;

    return (*fpga_reg >> flag) & 0x01;
}

uint32_t i = 0;

int main()
{
    fd = open("/dev/mem", O_RDWR | O_SYNC);
    if (fd < 0) {
        printf("Can't open memory.\n");
        return -1;
    }

    lw_base = mmap(NULL, H2F_AXI_LW_SPAN, PROT_READ|PROT_WRITE, MAP_SHARED, fd, H2F_AXI_LW_BASE_ADDR);
    fb_base = mmap(NULL, H2F_AXI_FB_SPAN, PROT_READ|PROT_WRITE, MAP_SHARED, fd, H2F_AXI_FB_BASE_ADDR);
    fpga_base = mmap(NULL, FPGA_MEM_SPAN, PROT_READ|PROT_WRITE, MAP_SHARED, fd, FPGA_MEM_BASE);
    if (lw_base == MAP_FAILED || fb_base == MAP_FAILED || fpga_base == MAP_FAILED) {
        printf("Can't map memory.\n");
        close(fd);
        return -1;
    }

    signal(SIGINT, handler);

    hps_reg    =  (uint8_t*)(lw_base + HPS_REG_OFFSET);
    fpga_reg   =  (uint8_t*)(lw_base + FPGA_REG_OFFSET);
    system_in  = (uint32_t*)(fb_base + SYSTEM_IN_OFFSET);
    system_out = (uint32_t*)(fpga_base + SYSTEM_OUT_OFFSET);

    set_flag(HPS_RESETN, CLEAR_FLAG);

    FILE* in_file = fopen("vhdl_cube_discrete_bin.csv", "r");
    if (!in_file) return -1;

    char line[514];
    uint32_t in_binary = 0;
    uint32_t in_cube_index = 0;
    uint32_t *in_cube;

    in_cube = (uint32_t*)(fpga_base + SYSTEM_IN_OFFSET); //Store the data in the reserved memory

    printf("Reading input file: \n");
    uint32_t counter = 0;
    while (fgets(line, sizeof(line), in_file)) {
        counter++;
        if (!(counter % 1000)) printf("\t%d/8192 (%f%c)\n", counter, counter/8192.0*100.0, 37);
        
        for (i = 0; i < 512; i++) {
            
            in_binary = in_binary << 1;
            if (line[i] == '1') {
                in_binary = in_binary | 0x00000001;
            }

            if ((i % 32) == 31) {
                in_cube[in_cube_index] = in_binary;
                in_cube_index++;
                in_binary = 0;
            }
        }
    }
    printf("%d/8192 (%f%c)\n", counter, counter/8192.0*100.0, 37);

    fclose(in_file);
    //printf("%x\n", *fpga_reg);
    set_flag(HPS_RESETN, SET_FLAG);
    set_flag(HPS_ACTIVE, SET_FLAG);
    //printf("%x\n", *fpga_reg);

    //FILE* f = fopen("salida.txt", "w");
    //if (!f) return 1;
    printf("Data transfer to FPGA: \n");
    counter = 0;
    for (i = 0; i < 131072; i++) {
        system_in[i % 16] = in_cube[i];
        counter++;
        if (!(counter % 10000)) printf("\t%d/131072 (%f%c)\n", counter, counter/131072.0*100.0, 37);
        //fprintf(f, "%08x ", in_cube[i]);
        //if (i % 16 == 15) fprintf(f, "\n");
    }
    printf("%d/131072 (%f%c)\n", counter, counter/131072.0*100.0, 37);
    //fclose(f);

    if (!get_flag(FPGA_ACTIVE) || get_flag(FPGA_IDLE)) {
        printf("FPGA did not start");
        return -2; //FPGA did not start
    }
    
    printf("FPGA ACTIVE\n");
    set_flag(HPS_SENT, SET_FLAG);
    
    usleep(10);

    if (!get_flag(FPGA_RECEIVED)) {
        printf("FPGA did not received");
        return -5; //FPGA did not start
    }

    printf("FPGA RECEIVED\n");

    while (!get_flag(FPGA_DONE)) usleep(1);
    printf("FPGA DONE\n");
    
    FILE* out_file = fopen("aesa_hps_result.txt", "w");
    if (!out_file) return -3;

    printf("Saving results: \n");
    for (i = 0; i < 131072; i = i + 2) {
        fprintf(out_file, "%05x ", system_out[i+1]);
        fprintf(out_file, "%05x ", system_out[i]);
        if (i % 64 == 62) fprintf(out_file, "\n");
    }

    set_flag(HPS_RECEIVED, SET_FLAG);
    
    return 0;
}