In this code I have used the Paul Debevec's method to calculate the camera response curves. This code is given in 
mycodeforcameraresponsefunction.m. First use this to generate the cameraresponse function for RGB channels.
THen run the code codeforartifacthdrimaging to generate the hdr image.
Then I used the method proposed in the paper. Artifact free HDR imaging to create ghostmaps. Instead of comparing the
images patch wise, I compared them at once. The pixels which differ from the relativeexposure map that generated
 from the reference image, were considered as ghost and marked as black. Then the images were fused to create the HDR image
The images are finally displayed using tone mapping using the bilateral tone mapping. 

References:

1) Gallo, Orazio, et al. "Artifact-free high dynamic range imaging." Computational Photography (ICCP), 2009 IEEE International Conference on. IEEE, 2009.

2) Heo, Yong Seok, et al. "Ghost-free high dynamic range imaging." Computer Vision–ACCV 2010. Springer Berlin Heidelberg, 2010. 486-500.

3) Durand, Frédo, and Julie Dorsey. "Fast bilateral filtering for the display of high-dynamic-range images." ACM transactions on graphics (TOG). Vol. 21. No. 3. ACM, 2002.

4) Debevec, Paul E., and Jitendra Malik. "Recovering high dynamic range radiance maps from photographs." ACM SIGGRAPH 2008 classes. ACM, 2008.