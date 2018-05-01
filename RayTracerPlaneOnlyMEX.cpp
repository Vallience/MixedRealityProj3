/*******
 * Author: Natasha Banerjee
 *
 * File to perform ray tracing for a plane without an object
 *
 */

#include <mex.h>
#include <cstdio>
#include <vector>
#include <cstdlib>
#include "BVH.h"
#include "Triangle.h"
    
using std::vector;


Vector3 interpVector( Vector3 v1, Vector3 v2, Vector3 v3, Vector3 mixingFactors ) {
    return v1*mixingFactors.x + v2*mixingFactors.y + v3*mixingFactors.z;
}

int raytrace(Vector3* planeVertices, Vector3 planeNormal, Vector3 planeColor,
             Vector3* envmapVertices, Vector3* envmapColors, int nEnvmapVertices,
             int height, int width, float f, float vx, float vy,
             double* outputIllumination, double* outputReflectance) {    
    mexPrintf("Done creating BVH\n");
    
    /* Two triangles for the ground plane */
    vector<Object*> planeTriangles;    
    
    planeTriangles.push_back( new Triangle( planeVertices[0], planeVertices[3], planeVertices[1],0 ) );
    planeTriangles.push_back( new Triangle( planeVertices[0], planeVertices[2], planeVertices[3],1 ) );        
    
    mexPrintf("Created plane array\n");
    
    Vector3 rayO = Vector3( 0.0, 0.0, 0.0 ); /* camera center is at (0, 0, 0) */
    
    /* Iterate over pixels */    
    mexPrintf("Start iterating over pixels\n");
    int npixels = width*height;
    for (size_t i=0; i < width; i++) {
        for (size_t j=0; j < height; j++) {           
            int index = (height * i + j);
            
            /* compute the coordinates of the direction of the ray through this pixel */
            float rayDX = ((float)i - vx) / f;
            float rayDY = ((float)j - vy) / f;
            float rayDZ = 1.0;
            
            Vector3 rayD = Vector3( rayDX, rayDY, rayDZ );
            rayD = normalize( rayD );
            Ray ray( rayO, rayD );
            
            /* Check if the ray intersects the object */
            IntersectionInfo I;
            Vector3 hitLocation;            
            Vector3 n;
            Vector3 c;
            
            /* Check if the ray intersects the ground */
            bool intersected = planeTriangles[0]->getIntersection( ray, &I );
            if (!intersected) {
                intersected = planeTriangles[1]->getIntersection( ray, &I );
            }                
            
            if (intersected) {
                /* This point belongs to the ground plane */                    
                hitLocation = I.hit;                    
                n = planeNormal; /* get normal */
                c = planeColor; /* get color */
                
                /* Iterate over environment map
                   Get environment map intersections with object */
                Vector3 netIllumination = Vector3( .0, .0, .0 );
                
                for ( size_t k=0; k < nEnvmapVertices; k++) {
                    /* Get direction */
                    Vector3 pt = hitLocation+envmapVertices[k]*.1;
                    Ray envmapRay = Ray( pt, envmapVertices[k] );
                    IntersectionInfo eI;
                    
                    /* Use this environment map vertex only if the ray does not
                       intersect the object, i.e., the env map vertex is not occluded */
                    float ndotenvmapRay = n * envmapVertices[k]; /* dot product */
                    if ( ndotenvmapRay > 0 ) { /* env map vertex is above this triangle */
                        netIllumination = netIllumination + ndotenvmapRay * envmapColors[k]; /* lambertian illumination */                        
                    }                    
                }
                outputIllumination[index] = netIllumination.x; 
                outputIllumination[index+npixels] = netIllumination.y; 
                outputIllumination[index+2*npixels] = netIllumination.z;
                
                //Vector3 shading = netIllumination.cmul( c ); /* multiply r, g, and b channels separately */
                
                outputReflectance[index] = c.x; outputReflectance[index+npixels] = c.y; outputReflectance[index+2*npixels] = c.z;                                 
            } else {
                outputReflectance[index] = .0; outputReflectance[index+npixels] = .0; outputReflectance[index+2*npixels] = .0;                                 
                outputIllumination[index] = .0; outputIllumination[index+npixels] = .0; outputIllumination[index+2*npixels] = .0;
            }
        }
    }
    mexPrintf("End iterating over pixels\n");
    return 1;    
}

void computeNormals( Vector3* vertices, int* faces, int nVertices, int nFaces, Vector3* normals, bool faceFlag ) {
    for (size_t i=0; i<( faceFlag ? nFaces : nVertices); i++) {
        normals[i] = Vector3( .0, .0, .0 );
    }
            
    
    for (size_t i=0; i<nFaces; i++) {                
        Vector3 v1 = vertices[faces[i]];
        Vector3 v2 = vertices[faces[i+nFaces]];
        Vector3 v3 = vertices[faces[i+2*nFaces]];
        
        Vector3 n = ( (v2-v1) ^ (v3-v1) );
        if (length(n)>1e-6) {
            n = normalize(n);
        }
        
        if (faceFlag) {
            normals[i] = n;
        } else {
            normals[faces[i]] = normals[faces[i]] + n;
            normals[faces[i+nFaces]] = normals[faces[i+nFaces]] + n;
            normals[faces[i+2*nFaces]] = normals[faces[i+2*nFaces]] + n;
        }
    }
    
    if (!faceFlag) {
        for (size_t i=0; i<nVertices; i++) {
            if (length(normals[i])>1e-6) {
                normals[i] = normalize( normals[i] );
            }
        }
    }
}


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    // Function should be called as:
    //
    // Render = RayTracerMEX( objectVertices, objectFaces, objectColors, planeVertices, planeColor, ...
    //          envmapVertices, envmapColors, imageSize, focalLength, vanishingPoint, faceFlag );
    
    mexPrintf("Entered function\n");
    
    
    double* dObjectVertices = mxGetPr( prhs[0] );
    const size_t* dimObjectVertices = mxGetDimensions( prhs[0] );
    int nObjectVertices = dimObjectVertices[0];
    
    double* dObjectFaces = ( mxGetPr( prhs[1] ));
    const size_t* dimObjectFaces = mxGetDimensions( prhs[1] );
    int nObjectFaces = dimObjectFaces[0];        
    
    int* objectFaces = new int[nObjectFaces*3];
    for (size_t i=0; i<nObjectFaces*3; i++) {
        objectFaces[i] = ((int)dObjectFaces[i])-1;     
    }
    
    double* dObjectColors = mxGetPr( prhs[2] );
    
    double* dPlaneVertices = mxGetPr( prhs[0] );
    
    double* dPlaneColor = mxGetPr( prhs[1] );
    
    double* dEnvmapVertices = mxGetPr( prhs[2] );
    const size_t* dimEnvmapVertices = mxGetDimensions( prhs[2] );
    int nEnvmapVertices = dimEnvmapVertices[0];
    
    double* dEnvmapColors = mxGetPr( prhs[3] );
    
    double* dImageSize = mxGetPr( prhs[4] );
    int height = (int)dImageSize[0];
    int width = (int)dImageSize[1];
    
    double* dFocalLength = mxGetPr( prhs[5] );
    double focalLength = (int)dFocalLength[0];
    
    double* vanishingPoint = mxGetPr( prhs[6] );
    double vx = vanishingPoint[0];
    double vy = vanishingPoint[1];
        
    mwSize* dims = new mwSize[3];
    dims[0] = height; dims[1] = width, dims[2] = 3;
    plhs[0] = mxCreateNumericArray( 3, dims, mxDOUBLE_CLASS, mxREAL );
    double* outputIllumination = mxGetPr( plhs[0] );    
    plhs[1] = mxCreateNumericArray( 3, dims, mxDOUBLE_CLASS, mxREAL );
    double* outputReflectance = mxGetPr( plhs[1] );        
    
    int nPlaneVertices = 4;    
    
    Vector3* envmapVertices = new Vector3[nEnvmapVertices];
    Vector3* envmapColors = new Vector3[nEnvmapVertices];
           
    Vector3* planeVertices = new Vector3[nPlaneVertices];       
    
    for (size_t i=0; i<nEnvmapVertices; i++) {
        envmapVertices[i] = Vector3( dEnvmapVertices[i],
                dEnvmapVertices[i+nEnvmapVertices], dEnvmapVertices[i+2*nEnvmapVertices] );
        envmapColors[i] = Vector3( dEnvmapColors[i],
                dEnvmapColors[i+nEnvmapVertices], dEnvmapColors[i+2*nEnvmapVertices] );        
    }
    
    
    for (size_t i=0; i<nPlaneVertices; i++) {
        planeVertices[i] = Vector3( dPlaneVertices[i], dPlaneVertices[i+4], dPlaneVertices[i+8] );
    }
    
    Vector3 planeNormal = normalize( ( planeVertices[3]-planeVertices[1] ) ^ ( planeVertices[3]-planeVertices[0] ) );
    Vector3 planeColor = Vector3( dPlaneColor[0], dPlaneColor[1], dPlaneColor[2] );
    
    mexPrintf("Created Vector3 arrays\n");    
    raytrace(planeVertices, planeNormal, planeColor,
             envmapVertices, envmapColors, nEnvmapVertices,
             height, width, focalLength, vx, vy, outputIllumination, outputReflectance );
    
    mexPrintf("Done ray tracing\n");
    
    delete[] envmapVertices;
    delete[] envmapColors;
    delete[] planeVertices;   
}
