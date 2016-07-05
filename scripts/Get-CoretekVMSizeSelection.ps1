<#
.SYNOPSIS
Presents the user with a selection of valid VM sizes unless the "-NoUI" option is passed then a size is automatically selected.

.DESCRIPTION
Presents the user with a selection of valid VM sizes based on location and option VM.

.PARAMETER Location
The location where the VM will be migrated to.

.PARAMETER ASMInstanceSize
The ASM (i.e. "classic Azure") virtual machine size as a string (i.e. "instance size name").

.PARAMETER VM
The ASM (i.e. "classic Azure") VM object (Microsoft.WindowsAzure.Commands.ServiceManagement.Model.PersistentVMRoleListContext) to check size information in order to recommend an appropriate migration target size in Azure Resource Manager (ARM).

.PARAMETER RecommendationsOnly
Using this parameter with the -VM parameter will reduce the generated VM specification list to only recommended VM sizes only.

.PARAMETER NoBasic
Using this parameter will filter "basic" VM specifications out of the available list.

.PARAMETER PremiumStorageOnly
Using this parameter will filter out everything but VM specifications that allow premium storage only

.PARAMETER NoPremiumStorage
Using this parameter will filter out all VM specifications that allow premium storage

.PARAMETER NoUI
This parameter makes this script "silent" where it chooses the first available, recommended VM size.  This option is intended for automated scripts and it is highly recommended that the "-VM" parameter is used in conjunction with this option otherwise the very first option will be selected which is likely to be the smallest VM size available.

.EXAMPLE
PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize = .\Get-CoretekVMSizeSelection.ps1 -Location "East US" -VM $vm -RecommendationsOnly -NoBasic -NoUI

PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize
Standard_DS1
.EXAMPLE
PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize = .\Get-CoretekVMSizeSelection.ps1 -Location "East US" -VM $vm -RecommendationsOnly
Virtual Machine Sizes:
0 : Standard_DS1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
1 : Standard_D1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
2 : Standard_DS1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
3 : Standard_D1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
4 : Standard_A2 (3.5 GB RAM, 2 core(s), 4 Max Data Disks) [RECOMMENDED]
5 : Basic_A2 (3.5 GB RAM, 2 core(s), 4 Max Data Disks) [RECOMMENDED]
Enter number of selection: 5

PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize
Basic_A2
.EXAMPLE
PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize = .\Get-CoretekVMSizeSelection.ps1 -Location "East US" -VM $vm -RecommendationsOnly -NoBasic
Virtual Machine Sizes:
0 : Standard_DS1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
1 : Standard_D1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
2 : Standard_DS1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
3 : Standard_D1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
4 : Standard_A2 (3.5 GB RAM, 2 core(s), 4 Max Data Disks) [RECOMMENDED]
Enter number of selection: 2

PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize
Standard_DS1_v2
.EXAMPLE
PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize = .\Get-CoretekVMSizeSelection.ps1 -Location "East US" -VM $vm -NoBasic
Virtual Machine Sizes:
0 : Standard_A0 (0.75 GB RAM, 1 core(s), 1 Max Data Disks) [NOT RECOMMENDED]
1 : Standard_A1 (1.75 GB RAM, 1 core(s), 2 Max Data Disks) [NOT RECOMMENDED]
2 : Standard_DS1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
3 : Standard_D1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
4 : Standard_DS1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
5 : Standard_D1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
6 : Standard_A2 (3.5 GB RAM, 2 core(s), 4 Max Data Disks) [RECOMMENDED]
7 : Standard_D2_v2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
8 : Standard_A3 (7 GB RAM, 4 core(s), 8 Max Data Disks) 
9 : Standard_D2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
10 : Standard_DS2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
11 : Standard_DS2_v2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
12 : Standard_DS3_v2 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
13 : Standard_DS11_v2 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
14 : Standard_DS11 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
15 : Standard_DS3 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
16 : Standard_D3_v2 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
17 : Standard_D11_v2 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
18 : Standard_A4 (14 GB RAM, 8 core(s), 16 Max Data Disks) 
19 : Standard_A5 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
20 : Standard_D11 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
21 : Standard_D3 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
22 : Standard_A6 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
23 : Standard_D12 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
24 : Standard_D4_v2 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
25 : Standard_DS12 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
26 : Standard_D12_v2 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
27 : Standard_DS12_v2 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
28 : Standard_D4 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
29 : Standard_DS4 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
30 : Standard_DS4_v2 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
31 : Standard_DS5_v2 (56 GB RAM, 16 core(s), 32 Max Data Disks) 
32 : Standard_A8 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
33 : Standard_DS13_v2 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
34 : Standard_D13 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
35 : Standard_DS13 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
36 : Standard_A7 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
37 : Standard_D13_v2 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
38 : Standard_A10 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
39 : Standard_D5_v2 (56 GB RAM, 16 core(s), 32 Max Data Disks) 
40 : Standard_D14 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
41 : Standard_D14_v2 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
42 : Standard_DS14_v2 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
43 : Standard_A9 (112 GB RAM, 16 core(s), 16 Max Data Disks) 
44 : Standard_DS14 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
45 : Standard_A11 (112 GB RAM, 16 core(s), 16 Max Data Disks) 
46 : Standard_D15_v2 (140 GB RAM, 20 core(s), 40 Max Data Disks) 
47 : Standard_DS15_v2 (140 GB RAM, 20 core(s), 40 Max Data Disks) 
Enter number of selection: 10

PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize
Standard_DS2
.EXAMPLE
PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize = .\Get-CoretekVMSizeSelection.ps1 -Location "East US" -VM $vm
Virtual Machine Sizes:
0 : Standard_A0 (0.75 GB RAM, 1 core(s), 1 Max Data Disks) [NOT RECOMMENDED]
1 : Basic_A0 (0.75 GB RAM, 1 core(s), 1 Max Data Disks) [NOT RECOMMENDED]
2 : Standard_A1 (1.75 GB RAM, 1 core(s), 2 Max Data Disks) [NOT RECOMMENDED]
3 : Basic_A1 (1.75 GB RAM, 1 core(s), 2 Max Data Disks) [NOT RECOMMENDED]
4 : Standard_DS1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
5 : Standard_D1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
6 : Standard_DS1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
7 : Standard_D1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
8 : Standard_A2 (3.5 GB RAM, 2 core(s), 4 Max Data Disks) [RECOMMENDED]
9 : Basic_A2 (3.5 GB RAM, 2 core(s), 4 Max Data Disks) [RECOMMENDED]
10 : Basic_A3 (7 GB RAM, 4 core(s), 8 Max Data Disks) 
11 : Standard_D2_v2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
12 : Standard_A3 (7 GB RAM, 4 core(s), 8 Max Data Disks) 
13 : Standard_D2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
14 : Standard_DS2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
15 : Standard_DS2_v2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
16 : Standard_DS3_v2 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
17 : Standard_DS11_v2 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
18 : Standard_DS11 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
19 : Standard_DS3 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
20 : Standard_D3_v2 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
21 : Standard_D11_v2 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
22 : Basic_A4 (14 GB RAM, 8 core(s), 16 Max Data Disks) 
23 : Standard_A4 (14 GB RAM, 8 core(s), 16 Max Data Disks) 
24 : Standard_A5 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
25 : Standard_D11 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
26 : Standard_D3 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
27 : Standard_A6 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
28 : Standard_D12 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
29 : Standard_D4_v2 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
30 : Standard_DS12 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
31 : Standard_D12_v2 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
32 : Standard_DS12_v2 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
33 : Standard_D4 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
34 : Standard_DS4 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
35 : Standard_DS4_v2 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
36 : Standard_DS5_v2 (56 GB RAM, 16 core(s), 32 Max Data Disks) 
37 : Standard_A8 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
38 : Standard_DS13_v2 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
39 : Standard_D13 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
40 : Standard_DS13 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
41 : Standard_A7 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
42 : Standard_D13_v2 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
43 : Standard_A10 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
44 : Standard_D5_v2 (56 GB RAM, 16 core(s), 32 Max Data Disks) 
45 : Standard_D14 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
46 : Standard_D14_v2 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
47 : Standard_DS14_v2 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
48 : Standard_A9 (112 GB RAM, 16 core(s), 16 Max Data Disks) 
49 : Standard_DS14 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
50 : Standard_A11 (112 GB RAM, 16 core(s), 16 Max Data Disks) 
51 : Standard_D15_v2 (140 GB RAM, 20 core(s), 40 Max Data Disks) 
52 : Standard_DS15_v2 (140 GB RAM, 20 core(s), 40 Max Data Disks) 
Enter number of selection: 5

PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize
Standard_D1
.EXAMPLE
PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $r = .\Get-CoretekVMSizeSelection.ps1 -Location "East US" -ASMInstanceSize Small -RecommendationsOnly -NoBasic
ASM Size:
-------------------------------------------------------------
1.75 GB RAM
1 core(s)
2 Max Data Disks

ARM Virtual Machine Sizes:
-------------------------------------------------------------
0 : Standard_A1 (1.75 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
Enter number of selection: 0

PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $r
Standard_A1

.EXAMPLE
PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $r = .\Get-CoretekVMSizeSelection.ps1 -Location "East US" -ASMInstanceSize Small -RecommendationsOnly
ASM Size:
-------------------------------------------------------------
1.75 GB RAM
1 core(s)
2 Max Data Disks

ARM Virtual Machine Sizes:
-------------------------------------------------------------
0 : Standard_A1 (1.75 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
1 : Basic_A1 (1.75 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
Enter number of selection: 1

PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $r
Basic_A1

.EXAMPLE
PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $r = .\Get-CoretekVMSizeSelection.ps1 -Location "East US" -ASMInstanceSize Small
ASM Size:
-------------------------------------------------------------
1.75 GB RAM
1 core(s)
2 Max Data Disks

ARM Virtual Machine Sizes:
-------------------------------------------------------------
0 : Standard_A0 (0.75 GB RAM, 1 core(s), 1 Max Data Disks) [NOT RECOMMENDED]
1 : Basic_A0 (0.75 GB RAM, 1 core(s), 1 Max Data Disks) [NOT RECOMMENDED]
2 : Standard_A1 (1.75 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
3 : Basic_A1 (1.75 GB RAM, 1 core(s), 2 Max Data Disks) [RECOMMENDED]
4 : Standard_DS1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) 
5 : Standard_D1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) 
6 : Standard_DS1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) 
7 : Standard_D1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) 
8 : Standard_A2 (3.5 GB RAM, 2 core(s), 4 Max Data Disks) 
9 : Basic_A2 (3.5 GB RAM, 2 core(s), 4 Max Data Disks) 
10 : Basic_A3 (7 GB RAM, 4 core(s), 8 Max Data Disks) 
11 : Standard_D2_v2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
12 : Standard_A3 (7 GB RAM, 4 core(s), 8 Max Data Disks) 
13 : Standard_D2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
14 : Standard_DS2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
15 : Standard_DS2_v2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
16 : Standard_DS3_v2 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
17 : Standard_DS11_v2 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
18 : Standard_DS11 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
19 : Standard_DS3 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
20 : Standard_D3_v2 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
21 : Standard_D11_v2 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
22 : Basic_A4 (14 GB RAM, 8 core(s), 16 Max Data Disks) 
23 : Standard_A4 (14 GB RAM, 8 core(s), 16 Max Data Disks) 
24 : Standard_A5 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
25 : Standard_D11 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
26 : Standard_D3 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
27 : Standard_A6 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
28 : Standard_D12 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
29 : Standard_D4_v2 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
30 : Standard_DS12 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
31 : Standard_D12_v2 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
32 : Standard_DS12_v2 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
33 : Standard_D4 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
34 : Standard_DS4 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
35 : Standard_DS4_v2 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
36 : Standard_DS5_v2 (56 GB RAM, 16 core(s), 32 Max Data Disks) 
37 : Standard_A8 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
38 : Standard_DS13_v2 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
39 : Standard_D13 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
40 : Standard_DS13 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
41 : Standard_A7 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
42 : Standard_D13_v2 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
43 : Standard_A10 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
44 : Standard_D5_v2 (56 GB RAM, 16 core(s), 32 Max Data Disks) 
45 : Standard_D14 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
46 : Standard_D14_v2 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
47 : Standard_DS14_v2 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
48 : Standard_A9 (112 GB RAM, 16 core(s), 16 Max Data Disks) 
49 : Standard_DS14 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
50 : Standard_A11 (112 GB RAM, 16 core(s), 16 Max Data Disks) 
51 : Standard_D15_v2 (140 GB RAM, 20 core(s), 40 Max Data Disks) 
52 : Standard_DS15_v2 (140 GB RAM, 20 core(s), 40 Max Data Disks) 
Enter number of selection: 2

PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $r
Standard_A1

.EXAMPLE
PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize = .\Get-CoretekVMSizeSelection.ps1 -Location "East US"
Virtual Machine Sizes:
0 : Standard_A0 (0.75 GB RAM, 1 core(s), 1 Max Data Disks) 
1 : Basic_A0 (0.75 GB RAM, 1 core(s), 1 Max Data Disks) 
2 : Standard_A1 (1.75 GB RAM, 1 core(s), 2 Max Data Disks) 
3 : Basic_A1 (1.75 GB RAM, 1 core(s), 2 Max Data Disks) 
4 : Standard_DS1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) 
5 : Standard_D1 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) 
6 : Standard_DS1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) 
7 : Standard_D1_v2 (3.5 GB RAM, 1 core(s), 2 Max Data Disks) 
8 : Standard_A2 (3.5 GB RAM, 2 core(s), 4 Max Data Disks) 
9 : Basic_A2 (3.5 GB RAM, 2 core(s), 4 Max Data Disks) 
10 : Basic_A3 (7 GB RAM, 4 core(s), 8 Max Data Disks) 
11 : Standard_D2_v2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
12 : Standard_A3 (7 GB RAM, 4 core(s), 8 Max Data Disks) 
13 : Standard_D2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
14 : Standard_DS2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
15 : Standard_DS2_v2 (7 GB RAM, 2 core(s), 4 Max Data Disks) 
16 : Standard_DS3_v2 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
17 : Standard_DS11_v2 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
18 : Standard_DS11 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
19 : Standard_DS3 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
20 : Standard_D3_v2 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
21 : Standard_D11_v2 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
22 : Basic_A4 (14 GB RAM, 8 core(s), 16 Max Data Disks) 
23 : Standard_A4 (14 GB RAM, 8 core(s), 16 Max Data Disks) 
24 : Standard_A5 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
25 : Standard_D11 (14 GB RAM, 2 core(s), 4 Max Data Disks) 
26 : Standard_D3 (14 GB RAM, 4 core(s), 8 Max Data Disks) 
27 : Standard_A6 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
28 : Standard_D12 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
29 : Standard_D4_v2 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
30 : Standard_DS12 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
31 : Standard_D12_v2 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
32 : Standard_DS12_v2 (28 GB RAM, 4 core(s), 8 Max Data Disks) 
33 : Standard_D4 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
34 : Standard_DS4 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
35 : Standard_DS4_v2 (28 GB RAM, 8 core(s), 16 Max Data Disks) 
36 : Standard_DS5_v2 (56 GB RAM, 16 core(s), 32 Max Data Disks) 
37 : Standard_A8 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
38 : Standard_DS13_v2 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
39 : Standard_D13 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
40 : Standard_DS13 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
41 : Standard_A7 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
42 : Standard_D13_v2 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
43 : Standard_A10 (56 GB RAM, 8 core(s), 16 Max Data Disks) 
44 : Standard_D5_v2 (56 GB RAM, 16 core(s), 32 Max Data Disks) 
45 : Standard_D14 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
46 : Standard_D14_v2 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
47 : Standard_DS14_v2 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
48 : Standard_A9 (112 GB RAM, 16 core(s), 16 Max Data Disks) 
49 : Standard_DS14 (112 GB RAM, 16 core(s), 32 Max Data Disks) 
50 : Standard_A11 (112 GB RAM, 16 core(s), 16 Max Data Disks) 
51 : Standard_D15_v2 (140 GB RAM, 20 core(s), 40 Max Data Disks) 
52 : Standard_DS15_v2 (140 GB RAM, 20 core(s), 40 Max Data Disks) 
Enter number of selection: 0

PS C:\Users\richa\Source\Repos\MigrationTools\MigrationTools\scripts> $instanceSize
Standard_A0
.NOTES
Author: Richard Sedlak - richard.sedlak@coretekservices.com
.INPUTS
Interactive and parameter-based only.
.OUTPUTS
Output type [string]

The Azure Resource Manager string assigned to the selected VM size.
#>

[CmdletBinding()]

param(
    [Parameter(Mandatory=$True)]
    [string]$Location,

    [Parameter(Mandatory=$False)]
    [string]$ASMInstanceSize="",

    [Parameter(Mandatory=$False)]
#    [Microsoft.WindowsAzure.Commands.ServiceManagement.Model.PersistentVMRoleListContext]$VM = $null,
<#
----------------------------------------------------------------------------------------------------------
The above type causes the Powershell help system to fail.  Needs to be revisited.
----------------------------------------------------------------------------------------------------------
#>
    $VM = $null,

    [Parameter(Mandatory=$False)]
    [switch]$RecommendationsOnly=$False,

    [Parameter(Mandatory=$False)]
    [switch]$NoBasic=$False,

    [Parameter(Mandatory=$False)]
    [switch]$PremiumStorageOnly=$False,

    [Parameter(Mandatory=$False)]
    [switch]$NoPremiumStorage=$False,

    [Parameter(Mandatory=$False)]
    [switch]$NoUI=$False
)


#region function definitions

function CTSBetween {
    param(
        [Parameter(Mandatory=$True)][int64]$value,
        [Parameter(Mandatory=$True)][int64]$min,
        [Parameter(Mandatory=$True)][int64]$max
    )

    Write-Debug ("v={0}, min={1}, max={2}" -f $value, $min, $max )

    $retval = $True

    # Error check - $max must be greater than $min
    if ( $min -gt $max ) { $retval = $False }

    if ( $retval ) {
        $range = $max - $min
        $delta = $max - $value

        if ( $delta -ge 0 -and $delta -le $range ) {
            $retval = $True
        }
        else {
            $retval = $False
        }
    }

    write-Debug ("retval={0}" -f $retval)

    return $retval
}

function filterVMList
{
    param(
        [Parameter(Mandatory=$True)]$vmspecs,
        [Parameter(Mandatory=$True)][Microsoft.WindowsAzure.Commands.ServiceManagement.Model.RoleSizeContext]$asmInstanceInfo,
        [Parameter(Mandatory=$True)][int64]$dc,
        [bool]$recommendationsOnly=$False
    )

    Write-Debug ("ENTERED filterVMList (vmspecs.Count={0},asmInstanceInfo={1},dc={2},recommendationsOnly={3})" -f $vmspecs.Count,$asmInstanceInfo,$dc,$recommendationsOnly)

    foreach ( $spec in $vmspecs )
    {
        $rstring = ""

        # check for [NOT RECOMMENDED]
        if ( $spec.NumberOfCores -lt $asmInstanceInfo.Cores -or $spec.MemoryInMB -lt $asmInstanceInfo.MemoryInMb -or $dc -gt $spec.MaxDataDiskCount ) {
            $rString = "[NOT RECOMMENDED]"
        }

        # check for [RECOMMENDED]
        if ( $rString -eq "" -and (CTSBetween $spec.NumberOfCores $asmInstanceInfo.Cores ([int64]$asmInstanceInfo.Cores+4)) `
                             -and (CTSBetween $spec.MemoryInMb $asmInstanceInfo.MemoryInMb ([decimal]$asmInstanceInfo.MemoryInMb*1.3)) `
                             -and (CTSBetween $dc $dc $spec.MaxDataDiskCount) ) {
            $rString = "[RECOMMENDED]"
        }

        Write-Debug ("rString={0}" -f $rString)

        Add-Member -InputObject $spec -NotePropertyName rString -NotePropertyValue $rString
    }

    Write-Debug ("RecommendationsOnly={0}" -f $recommendationsOnly)

    if ( $recommendationsOnly ) {
        $vmspecs = @($vmspecs | Where-Object {$_.rString -ne "[NOT RECOMMENDED]"})
        $list = @($vmspecs | Where-Object {$_.rString -eq "[RECOMMENDED]"})

        <#
            If the filtering fails (i.e. no recommendations found) then reset list to be the original list.
        #>
        if ( $list.Count -eq 0 -and $vmspecs.Count -gt 0 ) { $list = $vmspecs }
    }
    else { $list = $vmspecs }

    Write-Debug ("list.Count={0}" -f $list.Count)

    return $list
}

#endregion


#region Initialization

[string]$retval = "ERROR: General"

if ( $PremiumStorageOnly -and $NoPremiumStorage ) {
    Write-Error "You cannot specify -PremiumStorageOnly and -NoPremiumStorage at the same time.  It is an either/or relationship."
    $retval = "ERROR: You cannot specify -PremiumStorageOnly and -NoPremiumStorage at the same time.  It is an either/or relationship."
    return $retval
}

#endregion


#region get ASM Information for comparison
$asmInstanceInfo = $null

if ( $VM -ne $null ) {
    Write-Debug ("Name: {0}" -f $VM.Name)
    Write-Debug ("VM: {0}" -f $VM.VM)
    Write-Debug ("Instance Size: {0}" -f $VM.InstanceSize)

    $asmInstanceInfo = Get-AzureRoleSize -InstanceSize $VM.InstanceSize
}
elseif ( $ASMInstanceSize -ne "" ) {
    $asmInstanceInfo = Get-AzureRoleSize -InstanceSize $ASMInstanceSize
}

if ( $asmInstanceInfo -ne $null ) {
    Write-Debug ("Name: {0}" -f $asmInstanceInfo.InstanceSize)
    Write-Debug ("MemoryInMB: {0}" -f $asmInstanceInfo.MemoryInMb)
    Write-Debug ("Cores: {0}" -f $asmInstanceInfo.Cores)
    Write-Debug ("MaxDataDiskCount: {0}" -f $asmInstanceInfo.MaxDataDiskCount)    
}
#endregion


#region adjust RecommendationsOnly variable
if ( $asmInstanceInfo -eq $null ) { $RecommendationsOnly = $False }
#endregion


#region get ARM sizes


$vmspecs = @(Get-AzureRmVMSize -Location $Location | Sort-Object -Property MemoryInMB)

if ( $PremiumStorageOnly ) { $vmspecs = @($vmspecs | Where-Object {$_.Name -like "*DS*" }) }

if ( $NoBasic ) { $vmspecs = @($vmspecs | Where-Object {$_.Name -notlike "Basic*"}) }

if ( $asmInstanceInfo -ne $null ) {
    $dc = $asmInstanceInfo.MaxDataDiskCount

    if ( $VM -ne $null ) {
        $dc = @(Get-AzureDataDisk -VM $VM).Count
    }

    $vmspecs = @(filterVMList -vmspecs $vmspecs -asmInstanceInfo $asmInstanceInfo -dc $dc -recommendationsOnly $RecommendationsOnly.IsPresent)
}

if ( $NoUI -eq $False ) { # Interactive Mode

    Write-Host "ASM Size:"
    Write-Host "-------------------------------------------------------------"
    Write-Host ("{0} GB RAM" -f ($asmInstanceInfo.MemoryInMb/1024))
    Write-Host ("{0} core(s)" -f $asmInstanceInfo.Cores)
    Write-Host ("{0} Max Data Disks" -f $asmInstanceInfo.MaxDataDiskCount)
    Write-Host ""

    Write-Host "ARM Virtual Machine Sizes:"
    Write-Host "-------------------------------------------------------------"

    if ( $vmspecs.Count -eq 0 ) {
        Write-Host "None found"
        $retval = "ERROR: No VM Sizes to choose from in {0}" -f $Location
        Write-Error $retval
    }
    else {
        foreach ( $spec in $vmspecs ) {

            $str = "{0} : {1} ({2} GB RAM, {3} core(s), {4} Max Data Disks) {5}" `
                -f $vmspecs.IndexOf($spec), $spec.Name, ($spec.MemoryInMB/1024), $spec.NumberOfCores, $spec.MaxDataDiskCount, $spec.rString

            Write-Host $str

        }
        do {
            [bool]$selectionError = $True
            $selection = Read-Host "Enter number of selection"
            Write-Debug ("selection == {0}" -f $selection)
            if ( [int16]$selection -ge 0 -and [int16]$selection -lt $vmspecs.Count ) {
                $selectionError = $False
            }
            else {
                Write-Error ("Invalid selection: {0}" -f $selection)
                $selectionError = $True
            }
            "selectionError == {0}" -f $selectionError | Write-Debug
        }
        until ( $selectionError -eq $False )
        $retval = $vmspecs[$selection].Name
    }
}
else {
    $vmspecs = @($vmspecs | Where-Object { $_.rString -ne "[NOT RECOMMENDED]" } )

    if ( $vmspecs.Count -gt 0 ) { $retval = $vmspecs[0].Name }
    else {
        $retval = "ERROR: No VM Sizes Selected"
        Write-Error $retval
    }
}


#endregion


return $retval
