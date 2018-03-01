#ifndef Triangle_h_
#define Triangle_h_

#include <cmath>
#include "Object.h"
#include <algorithm>

struct Triangle : public Object {
    Vector3 p1;
    Vector3 p2;
    Vector3 p3;
    Vector3 center;
    int index;
  
  Triangle(const Vector3& inp1, const Vector3& inp2, const Vector3& inp3, int inindex)
    : p1(inp1), p2(inp2), p3(inp3) {
        center = (inp1 + inp2 + inp3) / 3.0f;
        index = inindex;
    }

  bool getIntersection(const Ray& ray, IntersectionInfo* I) const {
      Vector3 e1 = p2 - p1;
      Vector3 e2 = p3 - p1;
      Vector3 s1 = (ray.d ^ e2); // cross product
      float divisor = s1 * e1; // dot product
      
      if (divisor == 0.)
          return false;
      float invDivisor = 1.f / divisor;
      
      // Compute first barycentric coordinate
      Vector3 d = ray.o - p1;
      float b1 = (d * s1) * invDivisor;
      if (b1 < 0. || b1 > 1.)
          return false;
      
      // Compute second barycentric coordinate
      Vector3 s2 = (d ^ e1);
      float b2 = (ray.d * s2) * invDivisor;
      if (b2 < 0. || b1 + b2 > 1.)
          return false;
      
      // Compute _t_ to intersection point
      float t = (e2 * s2) * invDivisor;
      
      I->object = this;
      I->t = t;
      I->hit = ray.o + t*ray.d;
      I->barycentrics = Vector3( 1.0-b1-b2, b1, b2 );
      
      
      return true;
  }

  Vector3 getNormal(const IntersectionInfo& I) const {
    return normalize(I.hit - center);
  }
  
  int getIndex() const {
      return index;
  }

  BBox getBBox() const {
      return BBox( min( min(p1, p2), p3 ), max( max( p1, p2 ),p3 ) );
  }

  Vector3 getCentroid() const {
    return center;
  }

};

#endif
