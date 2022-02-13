# <img src="images/Rosettascripts_banner.png">

Rosetta-scripts comprises a set of helper scripts for homology and *de novo* modeling with Rosetta.
Currently it contains the following Python and Unix utilities:


- **submitJobs**: running multiple Rosetta jobs in parallel using a `rna_denovo` master file
  <details>
  <summary>Usage</summary>
  
  ```
  submitJobs -i <FARFAR input script> [-d <directory>] [-p <number of processors>]
  ```
  </details>
- **extract_pdb**: extract decoys from a Rosetta silentfile and optionally concatenate them into a single multi-model PDB file
  <details>
  <summary>Usage</summary>
  
  ```
  extract_pdb -s <silentfile> -f <folder with silentfiles> -n <number of models> -e <extract pdbs (true|false, default: true)> -m <merge pdbs (true|false, default: false)>
  ```
  </details>
- **pdb_resi_renumber.py**: renumber the residues of a PDB file
  <details>
  <summary>Usage</summary>
  
  ```
  pdb_resi_renumber.py [-h] [--version] -pdb PDB [-i] -e EDIT [-o O]

  renumber residues in PDB files

  optional arguments:
    -h, --help            show this help message and exit
    --version             show program's version number and exit
    -pdb PDB              pdb input file (.pdb)
    -i                    in-place modification
    -e EDIT, --edit EDIT  'oldResi>newResi' (use "," to separate individual residues and "-" for residue ranges; e.g. '2-4,5>A:6-8,9')
    -o O                  pdb output filename
  ```
  </details>
- **process_silentfile.sh**: remove non-standard residues from a silentfile
  <details>
  <summary>Usage</summary>
  
  ```
  process_silentfile -s <silentfile>
  ```
  </details>
