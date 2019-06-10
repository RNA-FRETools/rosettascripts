#!/usr/bin/python3
# F.Steffen, July 2018

import sys
import argparse
import numpy as np
import re
import Bio.PDB as bp


def parseCmd(version):
    """
    Parse the command line

    Parameters:
    ----------
    version : float

    Returns:
    -------
    pdbfile : string with input PDB file
    editline : string containing the chain and residues to modified
    inplace : boolean; file modification in place (default: False)
    
    """

    parser = argparse.ArgumentParser(description='renumber residues in PDB files')
    parser.add_argument('--version', action='version', version='%(prog)s ' + str(version))
    parser.add_argument('-pdb', help='pdb input file (.pdb)', required=True)
    parser.add_argument('-i', help='in-place modification', action='store_true') # no argument required
    parser.add_argument('-e', '--edit', help='\'oldResi>newResi\' (use "," to separate individual residues and "-" for residue ranges; e.g. \'2-4,5>A:6-8,9\')', required=True)
    parser.add_argument('-o', help='pdb output filename', required=False)    
    args = parser.parse_args()
    return args.pdb, args.edit, args.i, args.o


def parseEdit(editline):
    """
    Parse the edit line 
    
    Parameters:
    ----------
    editline : string containing the chain and residues to modified 
               e.g. \'2-4,5>A:6-8,9\' into [[' ', 2], [' ', 3], ...] and [['A', 6], ['A', 7], ...] 

    Returns:
    -------
    residues : dictionary containing list of lists with chain(s) and residue(s) to be modified

    """
    splt = editline.split('>')
    residues = {'old': [], 'new':[]}
    for q,on in enumerate(['old', 'new']):
        for r in splt[q].split(','):
            res = re.findall('([A-Z])?\:?(\d+)\-?', r)
            rInt = [int(i[1]) for i in res]
            if len(rInt) == 2:
                rIntRng = range(rInt[0], rInt[1]+1)
            else:
                rIntRng = rInt
            chRng = [res[0][0]]*len(rIntRng)  # replicate the first chain for all subsequent chain entries
            chRes = [list(rc) for rc in zip(chRng, rIntRng)] # recombine chain and residue
            residues[on].extend(chRes)
        # check for empty chains
        for i,_ in enumerate(residues[on]):
            if residues[on][i][0] == '':
                residues[on][i][0] = ' '
    
    # check if length of old and new residue list is equal
    if len(residues['old']) != len(residues['new']):
        print('-> Error: old residues and new residues do not have the same length')
        sys.exit()
    else:
        return residues


def loadPDB(pdbfile):
    """
    Load a PDB file into a structure object

    Parameters:
    ----------
    pdbfile : string with input PDB file
    
    Returns:
    -------
    structure_id : string with filename or PDB code (no file extension)
    structure : class object that follows the Structure/Model/Chain/Residue/Atom (SMCRA) architecture

    """
    pdbParser = bp.PDBParser(PERMISSIVE=1)
    structure_id = pdbfile[:-4]
    structure = pdbParser.get_structure(structure_id, pdbfile)
    return structure_id, structure


def check_chain_resi_exist(structure_id, model, residues):
    """
    Check if the specified chain and residues exists in the structure object
    
    Parameters:
    ----------
    structure_id : string with filename or PDB code (no file extension)
    model : class object referring to a model within the structure class
    residues : dictionary containing list of lists with chain(s) and residue(s) to be modified

    """
    for (oC, oR) in residues['old']:

        if oC not in [c.id for c in model.get_chains()]:
            print(list(model.get_chains()))
            print('-> Error: chain \'{}\' is not present in structure \'{}\''.format(oC, structure_id))
            sys.exit() 

        if oR not in [r.id[1] for r in model[oC].get_residues()]:
            print('-> Error: residue \'{}\' is not present in chain \'{}\' of structure \'{}\''.format(oR, oC, structure_id))
            sys.exit()
    return


def renumber(structure_id, structure, mdl, residues):
    """
    Reassign a new chain ID
    
    Parameters:
    ----------
    structure_id : string with filename or PDB code (no file extension)        
    structure : class object that follows the Structure/Model/Chain/Residue/Atom (SMCRA) architecture
    mdl : integer specifying a model within the structure class
    residues : dictionary containing list of lists with chain(s) and residue(s) to be modified

    Returns:
    -------
    structure : chain modified class object

    """
    model = structure[mdl]    
    check_chain_resi_exist(structure_id, model, residues)
    
    
    def reassign(oC, oR, nC, nR):
    
        if oC == nC:
            model[oC][oR].id = (' ', nR, ' ')
        else:   
            # check if new chain is already present in model         
            chainIDs = [c.id for c in model.get_chains()]  # chainIDs will be updated on every iteration        
            if nC not in chainIDs:
                if nC is not '?':
                    print('-> Note: chain \'{}\' is not present in \'{}\'. Adding it to the structure'.format(nC, structure_id))
                model.add(bp.Chain.Chain(nC))
        
            # add residue to new chain
            model[nC].add(bp.Residue.Residue((' ', nR, ' '), model[oC][oR].resname, model[oC][oR].segid))
            
            # copy all atoms from old residue in the old chain over to the new residue in the new chain
            atomIDs = [a.id for a in model[oC][oR].get_atoms()]
            for a in atomIDs:  
                model[nC][nR].add(model[oC][oR][a])
        
            # finally remove the residue from the old chain
            model[oC].detach_child((' ', oR, ' '))
        return model

        
    # Note: assignment proceeds in two steps: if one residue is assigned to a new residue that is already present in the structure, the old residue is insted assigned to a temporary dummy chain, to give the other residue a chance to be reassigned as well (e.g. 1-2>2-3; 1 will be assigned to 2 but 2 is still present at the time of assignment, thus 1 is assigned to ?:2 instead. When 2 is then assigned to 3, ?:2 can be assigned to its finally value: 2. 
    isPres = []
    for i, ((oC_ori,oR_ori), (nC_ori,nR_ori)) in enumerate(zip(residues['old'], residues['new'])):
        # check if new chain and new resi are part of the current structure
        if (nC_ori, nR_ori) in [(c.id, r.id[1]) for c in model.get_chains() for r in c.get_residues()]:
            isPres.append(True)
            # assign to dummy chain
            reassign(oC_ori, oR_ori, '?', nR_ori)
        else:
            isPres.append(False)
            # assign to new chain and new resi
            reassign(oC_ori, oR_ori, nC_ori, nR_ori)
            print('-> residue \'{}:{}\' has been assigned to \'{}:{}\'.'.format(oC_ori, oR_ori, nC_ori, nR_ori))


    for i, ((oC_ori,oR_ori), (nC_ori,nR_ori)) in enumerate(zip(residues['old'], residues['new'])):
        if isPres[i]:
            # try to assign dummy chain to new chain
            try:
                reassign('?', nR_ori, nC_ori, nR_ori)
                print('-> residue \'{}:{}\' has been assigned to \'{}:{}\'.'.format(oC_ori, oR_ori, nC_ori, nR_ori))            
            except:
                print('-> Error: residue \'{}:{}\' could not be assigned to \'{}:{}\' since that residue already exists. No output is generated'.format(oC_ori, oR_ori, nC_ori, nR_ori))
                sys.exit()
        
    return structure


def writePDB(structure_id, structure, inplace, outputfile):
    """
    Write PDB file to directory
            
    Parameters:
    ----------
    structure_id : string with filename or PDB code (no file extension)    
    structure : class object that follows the Structure/Model/Chain/Residue/Atom (SMCRA) architecture
    inplace : boolean; file modification in place (default: False)

    """
    io = bp.PDBIO()
    io.set_structure(structure)
    if inplace:
        renumber = ''
    elif outputfile is not None:
        structure_id = outputfile.replace('.pdb', '')
        renumber = ''
    else:
        renumber = '_renum'
    io.save('{}{}.pdb'.format(structure_id, renumber))
    print('=> Successfully renumbered (ID: {}) and written to directory (\'{}{}.pdb\').'.format(structure_id, structure_id, renumber))
    return

if __name__ == "__main__":
    version = 1.0
    pdbfile, editline, inplace, outputfile = parseCmd(version)
    residues = parseEdit(editline)
    structure_id, structure = loadPDB(pdbfile)
    structure_renum = renumber(structure_id, structure, 0, residues)    
    writePDB(structure_id, structure_renum, inplace, outputfile)
