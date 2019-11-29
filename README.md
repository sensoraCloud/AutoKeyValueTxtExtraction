## Auto Key-Value extraction from texts


### Reference Documentation

Please refere to docs\data_extraction_RoccoDeRosa.pdf for a full guide of the procedure.

### DIRECTORIES

check_point\.. Check point files. See Documentation

dataset\..  Example documents

docs\..   Documentation

edit_distance\..  class files for calculate distances

functions\..  class funtions extraction key 

results\..   output result files


### GENERATION OF KEY VALUES

- Main class: data_extraction.m

- Set INPUT parameters in the header of the main class

- Puts documents in dataset\..

- Put synonimus file (es. syns_Claim.xls) in the root dir

- Run data_extraction.m

- You can read the results in: \results\output.csv

### FILTERING AND CLEANING VALUES

- Run the Mathematica Notebook post_filtering.nb

- The intermediate results are placed in the folder check_point/post_process

- You can read the final results in: \results\output_complete.csv

