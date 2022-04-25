# ShowBrainSurf
Function to quickly render values (stats, cortical thickness, etc.) onto brain surfaces, or to show atlas defined ROIs on the brain surface

## Example 1:
You want to create a figure showing a subset of atlas defined ROIs.

usage:
> showbrainsurf;

Two popup menus will appear, the first allowing selection of the atlas (see below) and the second allowing for the selection of any number of ROIs defined by that atlas. Each selected ROI will be displayed in a unique color selected from a set of maximally distinguishable colors based on the number of ROIs selected. The result may look like:
![Example_Destrieux_SelectROIs](https://user-images.githubusercontent.com/98111478/165158176-fb292ca1-a964-46a6-b383-5345658b7ebb.png)




## Example 2:
Cohen's D effect sizes mapped onto the Gordon Atlas functional parcellation (333 ROIs; Gordon EM, et al. Cerebral Cortex, Volume 26, Issue 1, January 2016, Pages 288–303, https://doi.org/10.1093/cercor/bhu239)

usage:
> showbrainsurf(X);

where X is a 333x1 vector containing Cohen's D effect sizes.
![Example_GordonAtlas_Stats](https://user-images.githubusercontent.com/98111478/165102872-b01118d5-831f-4aea-971f-556bdf6f0564.png)

