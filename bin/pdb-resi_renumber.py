#!/usr/bin/python3
# F.Steffen, July 2018

import sys
import argparse
import numpy as np
import re
import Bio.PDB as bp


def parseCmd(version):
    """
    command line parser to get
    """

    parser = argparse.ArgumentParser(description='renumber residues in PDB files')
    parser.add_argument('--version', action='version', version='%(prog)s ' + str(version))
    parser.add_argument('-pdb', help='pdb input file (.pdb)', required=True)
    parser.add_argument('-i', help='in-place modification', action='store_true') # no argument required
    parser.add_argument('-e', '--edit', help='\'oldResi>newResi\' (use "," to separate individual residues and "-" for residue ranges; e.g. \'3-5>6-8\')', required=True)
    args = parser.parse_args()
    return args.pdb, args.edit, args.i


def parseEdit(editline):
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
        print('old residues and new residues do not have the same length')
        sys.exit()
    else:
        return residues


def loadPDB(pdbfile):
    pdbParser = bp.PDBParser(PERMISSIVE=1)
    structure_id = pdbfile[:-4]
    structure = pdbParser.get_structure(structure_id, pdbfile)
    return structure, structure_id

def checkChainExists(structure_id, model, residues):
    for chain in residues['old']:
        try:
            chain = model[chain[0]]
        except:
            print('chain \'{}\' is not present in structure \'{}\''.format(chain[0], structure_id))
            sys.exit()
    return

def checkResExists(structure_id, model, residues):
    for res in residues['old']:
        try:
            resi = model[res[0]][res[1]]
        except:
            print('residue \'{}\' is not present in chain \'{}\' of structure \'{}\''.format(res[1], res[0], structure_id))
            sys.exit()
    return

def checkChainNumber(model, residues):
    if len(np.unique([r[0] for r in residues['new']])) > len(np.unique([r[0] for r in residues['old']])):
        print('cannot create two chain from a single one')
        sys.exit()
    return

def alterChain(structure, mdl, residues):
    uniqueOld = np.unique([r[0] for r in residues['old']])
    uniqueNew = np.unique([r[0] for r in residues['new']])
    for oC, nC in zip(uniqueOld, uniqueNew):
        if nC != oC:
            structure[mdl][oC].id = nC
            print('Note: you have specified a new chain: \'{}\'. All residues belonging to former chain \'{}\' have been reassigned to chain \'{}\'.'.format(nC, oC, nC))
    return structure

def alterResi(structure, structure_id, mdl, residues):
    checkChainExists(structure_id, structure[mdl], residues)
    checkChainNumber(structure[mdl], residues)
    checkResExists(structure_id, structure[mdl], residues)
    # renumber residues
    for oRC, nRC in zip(residues['old'], residues['new']):
        res = structure[mdl][oRC[0]][oRC[1]]
        res.id = (res.id[0], nRC[1], res.id[2])
        print('residue \'{}\' has been assigned to \'{}\'.'.format(oRC[1], nRC[1]))
    return structure

def writePDB(structure, structure_id, inplace):
    io = bp.PDBIO()
    io.set_structure(structure)
    if inplace:
        renumber = ''
    else:
        renumber = '_renum'
    io.save('{}{}.pdb'.format(renumber, structure_id))
    print('Successfully renumbered (ID: {}) and written to directory (\'{}{}.pdb\').'.format(structure_id, structure_id, renumber))
    return

if __name__ == "__main__":
    version = 1.0
    pdbfile, editline, inplace = parseCmd(version)
    residues = parseEdit(editline)
    structure, structure_id = loadPDB(pdbfile)
    structure_renum = alterResi(structure, structure_id, 0, residues)
    structure_Chainrenum = alterChain(structure_renum, 0, residues)
    writePDB(structure_Chainrenum, structure_id, inplace)
