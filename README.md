# ShowBrainSurf
Function to quickly render values (stats, cortical thickness, etc.) onto brain surfaces, or to show atlas defined ROIs on the brain surface

## Example 1:
You want to create a figure showing a subset of atlas defined ROIs. Currently, ShowBrainSurf supports the Destrieux, Desikan-Killiany, Human Connectome Project Multimodal Parcellation, Gordon functional parcellation, and Schaefer 600 functional parcellation atlases.

usage:
> showbrainsurf;

Two popup menus will appear, the first allowing selection of the atlas and the second allowing for the selection of any number of ROIs defined by that atlas. Each selected ROI will be displayed in a unique color selected from a set of maximally distinguishable colors based on the number of ROIs selected. In the following example 12 regions were chosen from the Destrieux atlas (10 regions corresponding to the insula and 2 regions corresponding to the prefrontal gyrus):
![Example_Destrieux_SelectROIs](https://user-images.githubusercontent.com/98111478/165158176-fb292ca1-a964-46a6-b383-5345658b7ebb.png)


## Example 2:
You have a vector of data where each element corresponds to a coordinate on the FSAverage template or ROI in a supported atlas. In this example, I have a vector of size 333x1 where each element is a Cohen's D effect size for a corresponding Gordon Atlas functional parcellation region (333 ROIs; Gordon EM, et al. Cerebral Cortex, Volume 26, Issue 1, January 2016, Pages 288–303, https://doi.org/10.1093/cercor/bhu239)

usage:
> showbrainsurf(X);
![Example_GordonAtlas_Stats](https://user-images.githubusercontent.com/98111478/165102872-b01118d5-831f-4aea-971f-556bdf6f0564.png)

in this use case, if X is n-by-1 it will map the values to a colormap based on the values of X (if min(X)>=0, it will map min(X) to max(X) on the colormap hot; if max(X)<=0, it will map min(X) to max(X) on a black-blue-white colormap; otherwise it will map -max(abs(X)) to max(abs(X)) on a blue-white-red colormap as shown in the above picture. If X is n-by-3, each row is taken to be an RGB color for mapping.
