import setuptools

with open("README.md", "r") as fh:
    long_description = fh.read()

setuptools.setup(
    name="rosettapp",
    version="1.0.0",
    author="Fabio Steffen",
    author_email="fabio.steffen@chem.uzh.ch",
    description="Scripts for homology and de novo modeling using the Rosetta environment",
    long_description=long_description,
    long_description_content_type="text/markdown",
    url="https://github.com/fdsteffen/rosettapp",
    packages=setuptools.find_packages(exclude=['docs', 'tests']),
    classifiers=[
        "Programming Language :: Python :: 3",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
    ],
    keywords='Rosetta, modeling, FRET, PDB'
)
