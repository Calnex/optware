# Run minify based on provided parameters
#

import sys, getopt, os
import glob
from  subprocess import Popen, PIPE, STDOUT

yuiType=None
yuiOutput=None
yuiFolderExclusions=None
yuiFileInclusions=None
yuiFileExclusions=None
yuiFolder=None
yuiFolderSource=None
yuiVersion=None


def getArguments(argv):
    
    global yuiType
    global yuiOutput
    global yuiFolderExclusions
    global yuiFileInclusions
    global yuiFileExclusions
    global yuiScratchFolder
    global yuiFolderSource
    global yuiFolderDest
    global yuiJarFile
    
    try:
        opts,args = getopt.getopt(argv, "hi:o:", ["type=", "output=", "folder-exclusions=", "file-inclusions=", "file-exclusions=", "scratch-folder=", "file-list=", "folder-source=", "folder-dest=", "jar-file="])
    except getopt.GetoptError as e:
        print("Error in argument list {}".format(e))
        sys.exit(2)

    for opt,arg in opts:
        if opt == "--type":
            yuiType = arg
        elif opt == "--output":
            yuiOutput = arg
        elif opt == "--folder-exclusions":
            yuiFolderExclusions = arg
        elif opt == "--file-inclusions":
            yuiFileInclusions = arg
        elif opt == "--file-exclusions":
            yuiFileExclusions = arg
        elif opt == "--scratch-folder":
            yuiScratchFolder = arg
        elif opt == "--folder-source":
            yuiFolderSource = arg
        elif opt == "--jar-file":
            yuiJarFile = arg

# =========================================================================


def reportAndCheckArguments():
    if yuiType == None:
        print ("This file should not be called directly")
        sys.exit(3)
        
    # print("Arguments")
    # print("---------")
    # print()
    # print("    YUI Type:             {}".format(yuiType))
    # print("    YUI Output:           {}".format(yuiOutput))
    # print("    YUI FolderExclusions: {}".format(yuiFolderExclusions))
    # print("    YUI File Inclusions:  {}".format(yuiFileInclusions))
    # print("    YUI File Exclusions:  {}".format(yuiFileExclusions))
    # print("    YUI Scratch Folder:   {}".format(yuiScratchFolder))
    # print("    YUI Folder Source:    {}".format(yuiFolderSource))
    # print("    YUI Jar File:         {}".format(yuiJarFile))
    

# =========================================================================

def prepareForRun(outputFile):
    if os.path.isfile(outputFile):
        os.remove(outputFile)

# =========================================================================

def buildDirectoryList(path, exclusions):
    print ("\nBuild Directory List ({})".format(path))

    # This is a bit horrid; we want to be sure that the exlusions
    # are correct for our operating system
    #
    exclusions = exclusions.replace('\\', os.path.sep)
    exclusions = exclusions.replace('/', os.path.sep)
    print("    Exclusions list {}".format(exclusions))
    
    # And turn the input string into a list of folders
    excludedFolders = exclusions.split()
    
    allFolders = []
    
    folderCount=1
    allFolders.append(path)
    
    # Get a list of all folders
    #
    for root, subfolders, files in os.walk(path):
        for folder in subfolders:
            fullFolderName = os.path.join(root, folder)
            
            # Now check that the paths do not end with any of the exclusions
            #
            isExcluded = False
            for excludedFolder in excludedFolders:
                if fullFolderName.endswith(excludedFolder):
                    isExcluded = True
            
            # If this is not an excluded folder, add it to our list of
            # folders of interest
            #
            if not isExcluded:
                allFolders.append(fullFolderName)
                folderCount = folderCount + 1
                
    return allFolders

# =========================================================================

def buildFileList(folderList, includedFiles, excludedFiles):
    print ("Build file list")

    # Create an empty list of filenames
    allIncludedFiles = []
    
    # Build a list of permitted inclusion and types
    #
    fileInclusions = includedFiles.split()
    fileExclusions = excludedFiles.split()
    
    # Go through the folder list finding all files in the "included" list
    # then excluding any in the exclusions list
    #
    for folder in folderList:
        # For each file type we include, add a list of matching files
        # to the file list
        for fileInclusion in fileInclusions:
            newFiles = glob.glob(os.path.join(folder, includedFiles))
            
            # Now we have our list of files, we have to check manually 
            # that we shouldn't exclude this from the list
            for filename in newFiles:
                doInclude = True
                
                for exclusion in fileExclusions:
                    if filename.endswith(exclusion):
                        doInclude = False
                        
                if doInclude:
                    allIncludedFiles.append(filename)

    # All done
    return allIncludedFiles


# =========================================================================

def combineAndCheckCompression(files, jarFile, fileType):
    print ("Combine And Check Compression")
    
    # This step creates a single, uncompressed file.  
    # It goes through the input file list and for each file it:
    # - records the size of the original file, 
    # - compresses it to make sure it can be compressed
    # - records the size of the compressed file
    # - appends the original, uncompressed file to the output file.
    # and then it works out the overall compression ratio
    
    # This will store our uncomporessed file - let's hope we don't 
    # have multi-gigabyte javascript (for many reasons!)
    uncompressedFile = ""
    totalCompressedSize = 0
    
    
    for filename in files:
        print("    Adding {}".format(filename))

        # Read the file and append it to our "single uncompressed file"
        with open(filename, "r") as f:
            thisFile = f.read()
            uncompressedFile = uncompressedFile + thisFile

        proc = Popen(
            ['java -jar ' + jarFile + ' --type ' + fileType ],
            shell=True,
            stdin=PIPE,
            stdout=PIPE)
            
        compressedFile = proc.communicate(input=bytes(thisFile, "utf8"))[0]

        if proc.returncode != 0:
            raise ValueError("Error processing " + filename)
            
        totalCompressedSize = totalCompressedSize + len(compressedFile)
        
    return uncompressedFile
    
# =========================================================================

def createMinifiedFile(uncompressedFile, jarFile, fileType):
    print ("Create Minified File")

    proc = Popen(
        ['java -jar ' + jarFile + ' --type ' + fileType ],
        shell=True,
        stdin=PIPE,
        stdout=PIPE)
            
    compressedFile = proc.communicate(input=bytes(uncompressedFile, "utf8"))[0]

    if proc.returncode != 0:
        raise ValueError("Error processing complete file")
            
    print ("        Original size:   {}".format(len(uncompressedFile)))
    print ("        Compressed size: {}".format(len(compressedFile)))
    
    return compressedFile

# =========================================================================

def createOutputFile(compressedFile, filename):
    compressedFileAsString = compressedFile.decode(encoding='UTF-8')
    with open(filename, "w") as f:
        f.write(compressedFileAsString)

# =========================================================================


def main(argv):
    print ("Minifying Javascript")
    getArguments(argv)
    reportAndCheckArguments()

    prepareForRun(yuiOutput)
    folders = buildDirectoryList(yuiFolderSource, yuiFolderExclusions)
    files   = buildFileList(folders, yuiFileInclusions, yuiFileExclusions)
    
    uncompressedFile = combineAndCheckCompression(files, yuiJarFile, yuiType)
    compressedScript = createMinifiedFile(uncompressedFile, yuiJarFile, yuiType)

    createOutputFile(compressedScript, yuiOutput)
    
    print ("All done")


# Go!
if __name__ == "__main__":
   main(sys.argv[1:])
