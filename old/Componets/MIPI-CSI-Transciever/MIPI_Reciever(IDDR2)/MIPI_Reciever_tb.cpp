#include <verilatedos.h>
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <string.h>
#include <time.h>
#include <sys/types.h>
#include <signal.h>
#include "verilated.h"
#include "VMIPI_Reciever.h"
#include "testb.h"
#include <bitset>
#include"BigInt.hpp"
std::string hex_to_bits(const std::string& hex_string);
uint32_t shortpackage(int a,int b,int c);
const unsigned char BitReverseTable256[] =
{
  0x00, 0x80, 0x40, 0xC0, 0x20, 0xA0, 0x60, 0xE0, 0x10, 0x90, 0x50, 0xD0, 0x30, 0xB0, 0x70, 0xF0,
  0x08, 0x88, 0x48, 0xC8, 0x28, 0xA8, 0x68, 0xE8, 0x18, 0x98, 0x58, 0xD8, 0x38, 0xB8, 0x78, 0xF8,
  0x04, 0x84, 0x44, 0xC4, 0x24, 0xA4, 0x64, 0xE4, 0x14, 0x94, 0x54, 0xD4, 0x34, 0xB4, 0x74, 0xF4,
  0x0C, 0x8C, 0x4C, 0xCC, 0x2C, 0xAC, 0x6C, 0xEC, 0x1C, 0x9C, 0x5C, 0xDC, 0x3C, 0xBC, 0x7C, 0xFC,
  0x02, 0x82, 0x42, 0xC2, 0x22, 0xA2, 0x62, 0xE2, 0x12, 0x92, 0x52, 0xD2, 0x32, 0xB2, 0x72, 0xF2,
  0x0A, 0x8A, 0x4A, 0xCA, 0x2A, 0xAA, 0x6A, 0xEA, 0x1A, 0x9A, 0x5A, 0xDA, 0x3A, 0xBA, 0x7A, 0xFA,
  0x06, 0x86, 0x46, 0xC6, 0x26, 0xA6, 0x66, 0xE6, 0x16, 0x96, 0x56, 0xD6, 0x36, 0xB6, 0x76, 0xF6,
  0x0E, 0x8E, 0x4E, 0xCE, 0x2E, 0xAE, 0x6E, 0xEE, 0x1E, 0x9E, 0x5E, 0xDE, 0x3E, 0xBE, 0x7E, 0xFE,
  0x01, 0x81, 0x41, 0xC1, 0x21, 0xA1, 0x61, 0xE1, 0x11, 0x91, 0x51, 0xD1, 0x31, 0xB1, 0x71, 0xF1,
  0x09, 0x89, 0x49, 0xC9, 0x29, 0xA9, 0x69, 0xE9, 0x19, 0x99, 0x59, 0xD9, 0x39, 0xB9, 0x79, 0xF9,
  0x05, 0x85, 0x45, 0xC5, 0x25, 0xA5, 0x65, 0xE5, 0x15, 0x95, 0x55, 0xD5, 0x35, 0xB5, 0x75, 0xF5,
  0x0D, 0x8D, 0x4D, 0xCD, 0x2D, 0xAD, 0x6D, 0xED, 0x1D, 0x9D, 0x5D, 0xDD, 0x3D, 0xBD, 0x7D, 0xFD,
  0x03, 0x83, 0x43, 0xC3, 0x23, 0xA3, 0x63, 0xE3, 0x13, 0x93, 0x53, 0xD3, 0x33, 0xB3, 0x73, 0xF3,
  0x0B, 0x8B, 0x4B, 0xCB, 0x2B, 0xAB, 0x6B, 0xEB, 0x1B, 0x9B, 0x5B, 0xDB, 0x3B, 0xBB, 0x7B, 0xFB,
  0x07, 0x87, 0x47, 0xC7, 0x27, 0xA7, 0x67, 0xE7, 0x17, 0x97, 0x57, 0xD7, 0x37, 0xB7, 0x77, 0xF7,
  0x0F, 0x8F, 0x4F, 0xCF, 0x2F, 0xAF, 0x6F, 0xEF, 0x1F, 0x9F, 0x5F, 0xDF, 0x3F, 0xBF, 0x7F, 0xFF
};

int	main(int argc, char **argv) {
	Verilated::commandArgs(argc, argv);	
			//tb->m_core->lane0_d=a[i-52];
			//tb->m_core->lane0_d=((0x01370137b8)&(1<<(i-50)))/(pow(2,(i-50)));
			//tb->m_core->lane1_d=((0x3FF03FF0b8)&(1<<(i-50)))/(pow(2,(i-50)));
	TESTB<VMIPI_Reciever>	*tb
		= new TESTB<VMIPI_Reciever>;
	tb->opentrace("blinky.vcd");
	uint32_t data=(shortpackage(0x37,0x01,0x00));
	uint64_t lane0reg=(shortpackage(0x37,0x01,0x00));
	uint64_t lane1reg=shortpackage(0xF0,0x3f,0x00);



	//std::string a_string="100010000100100000111000001010000001100000001000000100010101010111000";
	//std::string b_string="100100001000000001000000001100000010000000010000011101000000010111000";

	std::string a_string=hex_to_bits("00F000FF0581C2C8B8BBF3B900FF022ab8");
	std::string b_string=hex_to_bits("00000100DFF87C755AD472DC02000E80b8");
	//std::string a_string=hex_to_bits("006900FF78D28C82784F1E1E00FF022ab8");
	//std::string b_string=hex_to_bits("00E50100E93C70E0C582C7F000000E80b8");
	
			bool* a =new bool[1000000];
			for (size_t i = 0; i < a_string.length()-1; i++)
			{				
					a[i]=a_string[a_string.length()-i-1]-'0';
			}
			bool* b =new bool[1000000];
			for (size_t i = 0; i < a_string.length()-1; i++)
			{					
					b[i]=b_string[b_string.length()-i-1]-'0';					
			}

	std::string a_string1=hex_to_bits("00F000FF0581C2C8B8BBF3B900FF022ab8");
	std::string b_string1=hex_to_bits("00000100DFF87C755AD472DC02000E80b8");
			bool* a1 =new bool[1000000];
			for (size_t i = 0; i < a_string1.length()-1; i++)
			{				
					a1[i]=a_string1[a_string1.length()-i-1]-'0';
			}
			bool* b1 =new bool[1000000];
			for (size_t i = 0; i < a_string1.length()-1; i++)
			{					
					b1[i]=b_string1[b_string1.length()-i-1]-'0';					
			}

	for (int i=0; i < 100000; i++) {
		//tb->m_core->lane0=((lane0reg)&(1<<i))/(pow(2,i));
		//tb->m_core->lane1=((lane1reg)&(1<<i))/(pow(2,i));
		if(i==0){
			tb->m_core->lane0_p=1;
			tb->m_core->lane0_n=1;
			tb->m_core->lane1_p=1;
			tb->m_core->lane1_n=1;
		}
		if(i==10){
			tb->m_core->lane0_p=0;
			tb->m_core->lane0_n=1;
			tb->m_core->lane1_p=0;
			tb->m_core->lane1_n=1;
		}
		if(i==20)
		{
			tb->m_core->lane0_p=0;
			tb->m_core->lane0_n=0;
			tb->m_core->lane1_p=0;
			tb->m_core->lane1_n=0;
		}
		if(i>=200)
		{
			
			
			//a=0x110907050301022ab8;
			//BigInt a=0x110907050301022ab8;
			//BigInt b=0x1210080604020E80b8;
			//tb->m_core->lane0_d=1&(0x110907050301022ab8>>(i-50));
			tb->m_core->lane0_d=a[i-200];
			tb->m_core->lane1_d=b[i-200];
			//tb->m_core->lane1_d=a[i-200];			
			//tb->m_core->lane1_d=1&(0x1210080604020E80b8>>(i-200));

		}
		if(i==5000){
			tb->m_core->lane0_p=1;
			tb->m_core->lane0_n=1;
			tb->m_core->lane1_p=1;
			tb->m_core->lane1_n=1;
		}
		if(i==5010){
			tb->m_core->lane0_p=0;
			tb->m_core->lane0_n=1;
			tb->m_core->lane1_p=0;
			tb->m_core->lane1_n=1;
		}
		if(i==5080)
		{
			tb->m_core->lane0_p=0;
			tb->m_core->lane0_n=0;
			tb->m_core->lane1_p=0;
			tb->m_core->lane1_n=0;
		}
		if(i>=5250)
		{
			
			
			//a=0x110907050301022ab8;
			//BigInt a=0x110907050301022ab8;
			//BigInt b=0x1210080604020E80b8;
			//tb->m_core->lane0_d=1&(0x110907050301022ab8>>(i-50));
			tb->m_core->lane0_d=a[i-5250];
			tb->m_core->lane1_d=b[i-5250];
			//tb->m_core->lane1_d=a[i-200];			
			//tb->m_core->lane1_d=1&(0x1210080604020E80b8>>(i-200));

		}
		if(i==10000){
			tb->m_core->lane0_p=1;
			tb->m_core->lane0_n=1;
			tb->m_core->lane1_p=1;
			tb->m_core->lane1_n=1;
		}
		if(i==10010){
			tb->m_core->lane0_p=0;
			tb->m_core->lane0_n=1;
			tb->m_core->lane1_p=0;
			tb->m_core->lane1_n=1;
		}
		if(i==10080)
		{
			tb->m_core->lane0_p=0;
			tb->m_core->lane0_n=0;
			tb->m_core->lane1_p=0;
			tb->m_core->lane1_n=0;
		}
		if(i>=10250)
		{
			
			
			//a=0x110907050301022ab8;
			//BigInt a=0x110907050301022ab8;
			//BigInt b=0x1210080604020E80b8;
			//tb->m_core->lane0_d=1&(0x110907050301022ab8>>(i-50));
			tb->m_core->lane0_d=a1[i-10250];
			tb->m_core->lane1_d=b1[i-10250];
			//tb->m_core->lane1_d=a[i-200];			
			//tb->m_core->lane1_d=1&(0x1210080604020E80b8>>(i-200));

		}

		if(i==15000){
			tb->m_core->lane0_p=1;
			tb->m_core->lane0_n=1;
			tb->m_core->lane1_p=1;
			tb->m_core->lane1_n=1;
		}
		if(i==15010){
			tb->m_core->lane0_p=0;
			tb->m_core->lane0_n=1;
			tb->m_core->lane1_p=0;
			tb->m_core->lane1_n=1;
		}
		if(i==15080)
		{
			tb->m_core->lane0_p=0;
			tb->m_core->lane0_n=0;
			tb->m_core->lane1_p=0;
			tb->m_core->lane1_n=0;
		}
		if(i>=15250)
		{
			
			
			//a=0x110907050301022ab8;
			//BigInt a=0x110907050301022ab8;
			//BigInt b=0x1210080604020E80b8;
			//tb->m_core->lane0_d=1&(0x110907050301022ab8>>(i-50));
			tb->m_core->lane0_d=a[i-15250];
			tb->m_core->lane1_d=b[i-15250];
			//tb->m_core->lane1_d=a[i-200];			
			//tb->m_core->lane1_d=1&(0x1210080604020E80b8>>(i-200));

		}
		tb->tick();
	}
	printf("\n\nSimulation complete\n");
}
uint32_t shortpackage(int a,int b,int c){
	int d[24]={};
	d[0]=(a)&0x01;
	d[1]=((a)&0x02)/2;
	d[2]=((a)&0x04)/4;
	d[3]=((a)&0x08)/8;
	d[4]=((a)&0x10)/16;
	d[5]=((a)&0x20)/32;
	d[6]=((a)&0x40)/64;
	d[7]=((a)&0x80)/128;
	//
	d[8]=(b)&0x01;
	d[9]=((b)&0x02)/2;
	d[10]=((b)&0x04)/4;
	d[11]=((b)&0x08)/8;
	d[12]=((b)&0x10)/16;
	d[13]=((b)&0x20)/32;
	d[14]=((b)&0x40)/64;
	d[15]=((b)&0x80)/128;
	//
	d[16]=(c)&0x01;
	d[17]=((c)&0x02)/2;
	d[18]=((c)&0x04)/4;
	d[19]=((c)&0x08)/8;
	d[20]=((c)&0x10)/16;
	d[21]=((c)&0x20)/32;
	d[22]=((c)&0x40)/64;
	d[23]=((c)&0x80)/128;
	printf("d:_%x_\n",d);
	uint32_t ecc=0;
	ecc|=((d[0])^(d[1])^(d[2])^(d[4])^(d[5])^(d[7])^(d[10])^(d[11])^(d[13])^(d[16])^(d[20])^(d[21])^(d[22])^(d[23]))<<24;
	ecc|=((d[0])^(d[1])^(d[3])^(d[4])^(d[6])^(d[8])^(d[10])^(d[12])^(d[14])^(d[17])^(d[20])^(d[21])^(d[22])^(d[23]))<<25;
	ecc|=((d[0])^(d[2])^(d[3])^(d[5])^(d[6])^(d[9])^(d[11])^(d[12])^(d[15])^(d[18])^(d[20])^(d[21])^(d[22]))<<26;
	ecc|=((d[1])^(d[2])^(d[3])^(d[7])^(d[8])^(d[9])^(d[13])^(d[14])^(d[15])^(d[19])^(d[20])^(d[21])^(d[23]))<<27;
	ecc|=((d[4])^(d[5])^(d[6])^(d[7])^(d[8])^(d[9])^(d[16])^(d[17])^(d[18])^(d[19])^(d[20])^(d[22])^(d[23]))<<28;
	ecc|=((d[10])^(d[11])^(d[12])^(d[13])^(d[14])^(d[15])^(d[16])^(d[17])^(d[18])^(d[19])^(d[21])^(d[22])^(d[23]))<<29;
	ecc|=a<<0;
	ecc|=b<<8;
	ecc|=c<<16;

	return ecc;
}

std::string hex_to_bits(const std::string& hex_string)
{
    const int num_hex_chars = hex_string.length(); // Anzahl der Hexadezimal-Ziffern
    const int num_bits = num_hex_chars * 4; // Anzahl der Bits im String
    std::string bit_string(num_bits, '0'); // String mit der berechneten Anzahl von Bits

    // Schleife durch die Hex-Ziffern des Strings
    for (int i = 0; i < num_hex_chars; i++) {
        // Konvertierung des aktuellen Hex-Wertes in einen int-Wert
        int hex_value;
        char hex_char = hex_string[i];
        if (hex_char >= '0' && hex_char <= '9') {
            hex_value = hex_char - '0';
        } else if (hex_char >= 'A' && hex_char <= 'F') {
            hex_value = hex_char - 'A' + 10;
        } else if (hex_char >= 'a' && hex_char <= 'f') {
            hex_value = hex_char - 'a' + 10;
        } else {
            throw std::invalid_argument("Ungültige Hexadezimal-Ziffer: " + std::string(1, hex_char));
        }

        // Konvertierung des aktuellen Hex-Wertes in ein Bit-Muster
        for (int j = 0; j < 4; j++) {
            int bit_pos = i * 4 + j; // Berechnung der Position des Bits im String
            bit_string[bit_pos] = ((hex_value & (1 << (3 - j))) != 0) ? '1' : '0'; // Setzen des Bits im String
        }
    }

    // Rückgabe des Bit-Strings
    return bit_string;
}