#include <iostream>
#include <fstream>
#include <string>

using namespace std;

//	2's comp binary
string twobin(int value) {
	string ret = "", ret1 = "";
	int flag = 1, i;

	while (flag == 1) {
		if (value % 2 == 1) {
			ret += "1";
		}
		else {
			ret += "0";
		}
		value /= 2;

		if (value == 0) {
			flag = 0;
		}
	}

	while (ret.length() <= 3) {
		ret += '0';
	}
	for (i = 2; i > -1; i--) {
		ret1 += ret[i];
	}

	return ret1;
}

// unsigned binary
string bin(int value) {
	string ret = "", ret1 = "";
	int flag = 1, i;

	while (flag == 1) {

		if (value % 2 == 1) {
			ret += "1";
		} else {
			ret += "0";
		}
		value /= 2;

		if (value == 0) {
			flag = 0;
		}
	}

	while (ret.length() <= 5) {
		ret += '0';
	}
	for (i = 4; i >= 0; i--) {
		ret1 += ret[i];
	}
	
	return ret1;
}
//	handles immediate
string LI_bin(int value) {
	string ret = "", ret1 = "";
	int flag = 1, i = 0;
 
	while (flag == 1) {
		if (value % 2 == 1) {
			ret += "1";
		}
		else {
			ret += "0";
		}
		value /= 2;

		if (value == 0) {
			flag = 0;
		}
	}
	
	while (ret.length() < 17) {
		ret += "0";
	}
	for (i = 15; i >= 0; i--) {
		ret1 += ret[i];
	}
	return ret1;
}

string r3instr(string line) {
	
	int r1_val, r2_val, rd_val, i = 0;
	string rd = "", r1 = "", r2 = "", ret = "";
	
	//	scroll until '$'
	while(line[i] != '$') {
		cout << line[i];
		i++;
	}
	i++;
	while(line[i] != ',') {
		cout << line[i];
		rd += line[i];
		i++;
	}
	
	while(line[i] != '$') {
		cout << line[i];
		i++;
	}
	i++;
	while(line[i] != ',') {
		cout << line[i];
		r1 += line[i];
		i++;
	}
	
	while(line[i] != '$') {
		cout << line[i];
		i++;
	}
	i++;
	while(line[i] != '\0') {
		cout << line[i];
		r2 += line[i];
		i++;
	}
	cout << endl;

	r1_val = stoi(r1);
	r2_val = stoi(r2);
	rd_val = stoi(rd);
	
	if (r1_val < 0 || r1_val > 31 || r2_val < 0 || r2_val > 31 || rd_val < 0 || rd_val > 31) {
		cerr << "R3 Bounds Error";
		exit(1);
	}

	if (r2_val == 0)
		ret += "00000";
	else
		ret += bin(r2_val);
		ret += bin(r1_val);
		ret += bin(rd_val);
	return ret;
}


string r4instr(string line) {
	int r1_val, r2_val, r3_val, rd_val, i = 0;
	string rd = "", r1 = "", r2 = "", r3 = "";
	
	while(line[i] != '$') {
		cout << line[i];
		i++;
	}
	i++;
	while (line[i] != ',') {
		cout << line[i];
		rd += line[i];
		i++;
	}
	
	while(line[i] != '$') {
		cout << line[i];
		i++;
	}
	i++;
	while (line[i] != ',') {
		cout << line[i];
		r1 += line[i];
		i++;
	}
	
	while(line[i] != '$') {
		cout << line[i];
		i++;
	}
	i++;
	while (line[i] != ',') {
		cout << line[i];
		r2 += line[i];
		i++;
	}
	
	while(line[i] != '$') {
		cout << line[i];
		i++;
	}
	i++;
	while (line[i] != '\0') {
		cout << line[i];
		r3 += line[i];
		i++;
	}
	cout << endl;

	r1_val = stoi(r1);
	r2_val = stoi(r2);
	r3_val = stoi(r3);
	rd_val = stoi(rd);


	string ret = "";

	if (r1_val < 0 || r1_val > 31 || r2_val < 0 || r2_val > 31 || r3_val < 0 || r3_val > 31 || rd_val < 0 || rd_val > 31) {
		cerr << "R4 Bounds Error";
		exit(1);
	}

	ret += bin(r3_val);
	ret += bin(r2_val);
	ret += bin(r1_val);
	ret += bin(rd_val);
	return ret;
}


int main() {
	

	string line, bin_line;
	ifstream in_dest;
	ofstream out_dest;

	int i;

	in_dest.open("assem.txt");
	out_dest.open("mipscode.txt");

	if (in_dest.fail()) {
		cout << "Cannot open file" << endl;
		exit(1);
	}

	
	while (getline(in_dest, line)) {

		if (line[0] == 'L' && line[1] == 'I') {
			bin_line = "";

			i = 3;
			string rd = "", offset = "", imm = "";
			int off_val, rd_val, flag = 0;

			while (line[i] != ',') {
				offset += line[i];
				i++;
			}


			off_val = stoi(offset);
			if (off_val > 7 || off_val < 0) {
				cout << "LI Offset error" << endl;
				exit(1);
			} 


			while(line[i] != '$') {
				i++;
			}
			i++;
			while (line[i] != ',') {
				rd += line[i];
				i++;
			}
		
			rd_val = stoi(rd);

			if (rd_val > -1 && rd_val < 32) {
	
				i += 2;

				if (line[i] == '-') {
					flag = 1;
					i++;
				}
				
				while (line[i] != '\0') {
					imm += line[i];
					i++;
				}
	
				int imm_val = stoi(imm);
	
				bin_line += '0';
				bin_line += twobin(off_val);

				if (imm_val == -32768) {
					bin_line += "1000000000000000";
				}

				else if (imm_val == 0) {
					bin_line += "0000000000000000";
				}

				else if (imm_val > 32767 || imm_val < -32768) {
					cout << "Immediate value out of bounds\n";
					exit(1);
				}
				else if (imm_val == 32767) {
					bin_line += "0111111111111111";
				}
				else if (flag == 0) {
					bin_line += LI_bin(imm_val);
				}
				
				else if (flag == 1) {
					string str = LI_bin(imm_val);
					int i;
					for (i = 0; i < 16; i++) {
						if (str[i] == '1')
							str[i] = '0';
						else
							str[i] = '1';
					}
	
					int carry = 1;
					i = 15;
					while (carry == 1) {
						if (str[i] == '1') {
							str[i] = '0';
							i--;
						}
						else {
							str[i] = '1';
							carry = 0;
						}
					}
					cout << str << endl;
					bin_line += str;
				}
				bin_line += bin(rd_val);

				out_dest << bin_line << endl;
			}
			else {
				cout << "Reg error \n";
				exit(1);
			
			}
			

		}

		else if (line[0] == 'S' && line[1] == 'I' && line[2] == 'M') {
			//bin_line = "";
			
		//SIMALS 
			if (line[0] == 'S' && line[1] == 'I' && line[2] == 'M' && line[3] == 'A' && line[4] == 'L' && line[5] == 'S') {
				bin_line = "10000" + r4instr(line);
			}

			//SIMAHS
			else if (line[0] == 'S' && line[1] == 'I' && line[2] == 'M' && line[3] == 'A' && line[4] == 'H' && line[5] == 'S') {
				bin_line = "10001" + r4instr(line);
			}

			//SIMSLS 
			else if (line[0] == 'S' && line[1] == 'I' && line[2] == 'M' && line[3] == 'S' && line[4] == 'L' && line[5] == 'S') {
				bin_line = "10010" + r4instr(line);
			}

			//SIMSHS
			else if (line[0] == 'S' && line[1] == 'I' && line[2] == 'M' && line[3] == 'S' && line[4] == 'H' && line[5] == 'S') {
				bin_line = "10011" + r4instr(line);
			}
			out_dest << bin_line << endl;
		}

		else if (line[0] == 'S' && line[1] == 'L' && line[2] == 'M') {
			//bin_line = "";

			//SLMALS 
			if (line[0] == 'S' && line[1] == 'L' && line[2] == 'M' && line[3] == 'A' && line[4] == 'L' && line[5] == 'S') {
				bin_line = "10100" + r4instr(line);
			}

			//SLMAHS 
			else if (line[0] == 'S' && line[1] == 'L' && line[2] == 'M' && line[3] == 'A' && line[4] == 'H' && line[5] == 'S') {
				bin_line = "10101" + r4instr(line);
			}
			//SLMSLS 
			else if (line[0] == 'S' && line[1] == 'L' && line[2] == 'M' && line[3] == 'S' && line[4] == 'L' && line[5] == 'S') {
				bin_line = "10110" + r4instr(line);
			}//else if

			//LMSHS 
			else if (line[0] == 'S' && line[1] == 'L' && line[2] == 'M' &&line[3] == 'S' && line[4] == 'H' && line[5] == 'S') {
				bin_line = "10111" + r4instr(line);
			}

			out_dest << bin_line << endl;
		}

					/*========================R3=================*/
		//NOP
		else if (line[0] == 'N' && line[1] == 'O' && line[2] == 'P') {
			bin_line = "1100000000000000000000000";
			out_dest << bin_line << endl;
			
		}

		//CLZW
		else if (line[0] == 'C' && line[1] == 'L' && line[2] == 'Z' && line[5] == 'W') {
			
			bin_line = "1100000001" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//AU
		else if (line[0] == 'A' && line[1] == 'U') {
			
			bin_line = "1100000010" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//AHU
		else if (line[0] == 'A' && line[1] == 'H' && line[2] == 'U') {
			
			bin_line = "1100000011" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//AHS
		else if (line[0] == 'A' && line[1] == 'H' && line[2] == 'S') {
			
			bin_line = "1100000100" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//AND
		else if (line[0] == 'A' && line[1] == 'H' && line[2] == 'S') {
			
			bin_line = "1100000101" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//BCW
		else if (line[0] == 'B' && line[1] == 'C' && line[2] == 'W') {
			
			bin_line = "1100000110" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//MAXWS
		else if (line[0] == 'M' && line[1] == 'A' && line[2] == 'X' && line[3] == 'W' && line[4] == 'S') {
			
			bin_line = "1100000111" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//MINWS
		else if (line[0] == 'M' && line[1] == 'I' && line[2] == 'N' && line[3] == 'W' && line[4] == 'S') {
			
			bin_line = "1100001000" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//MLHU
		else if (line[0] == 'M' && line[1] == 'L' && line[2] == 'H' && line[3] == 'U') {
			
			bin_line = "1100001001" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//MLHCU
		else if (line[0] == 'M' && line[1] == 'L' && line[2] == 'H' && line[3] == 'C' && line[4] == 'U') {
			
			bin_line = "1100001010" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//OR
		else if (line[0] == 'O' && line[1] == 'R') {
			
			bin_line = "1100001011" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//PCNTW
		else if (line[0] == 'P' && line[1] == 'C' && line[2] == 'N' && line[3] == 'T' && line[4] == 'W') {
			
			bin_line = "1100001100" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//ROTW
		else if (line[0] == 'R' && line[1] == 'O' && line[2] == 'T' && line[3] == 'W') {
			
			bin_line = "1100001101" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//SFWU
		else if (line[0] == 'S' && line[1] == 'F' && line[2] == 'W' && line[3] == 'U') {
			
			bin_line = "1100001110" + r3instr(line);
			out_dest << bin_line << endl;
		}
		//SFHS
		else if (line[0] == 'S' && line[1] == 'F' && line[2] == 'H' && line[3] == 'S') {
			
			bin_line = "1100001111" + r3instr(line);
			out_dest << bin_line << endl;
		}
	}
	return 0;
}