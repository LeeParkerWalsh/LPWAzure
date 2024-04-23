Sample project to set up an Azure Automation account and runbook that can administer a fileshare.

filemodified.ps1 is set with -whatif flag on remove to prevent it from being destructive out the box, season to taste here if need e.g. ability to remove files more than 90 days old.

Module structure is entirely over-engineered just to create additional problems of data in other modules, which then needs solutions - entirely possible to run flat.

![image](https://github.com/LeeParkerWalsh/LPWAzure/assets/93846587/2a125f97-5585-4f84-abe8-dccaf1df14bb)

Sample run in Azure showcasing script as handling multiple directory paths.
