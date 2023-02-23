# WM_VI_EVC

Hi there!

This is the complete pipeline to recreate the analysis and plots in our paper "Working memory signals in early visual cortex do not depend on visual imagery" by Weber, Christophel, Görgen, Soch and Haynes. To create the figures from the paper, open 'WM_VI_EVC/code/analysis/analysis_pipeline.m', complete a few file paths (look for '...') and then hit run (ignore the warning messages). If you have the original data (which can be made available upon reasonable request), you can also recreate the entire analysis. This might take very (very!) long, so computing clusters and parallelisation are key (look for the out-commented 'parfor' and 'parallel_pool' lines in the various functions). 

All (well, most) functions in this repository are commented fairly thoroughly, so I hope everything becomes clear with minimal (or at least medium) effort. In case it doesn't, or you have questions, feel free to email me at sweber@bccn-berlin.de.

There are a few external tools and toolboxes that are required to run the analysis. These are listed in 'WM_VI_EVC/code/analysis/analysis_pipeline.m', including their respective download links. Make sure that you all resources are available on your system and added to the Matlab search path.

Cheers!

Simon Weber, sweber@bccn-berlin.de, 2023
