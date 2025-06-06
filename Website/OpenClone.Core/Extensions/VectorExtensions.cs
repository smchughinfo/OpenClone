using Pgvector;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Extensions
{
    public static class VectorExtensions
    {
        /// <summary>
        /// Warning - this is slower than Pgvector.EntityFrameworkCore.CosineDistance, which is evaluated on the database
        /// </summary>
        /// <param name="vectorA"></param>
        /// <param name="vectorB"></param>
        /// <returns></returns>
        public static float ClientEvaluatedCosineDistance(this Pgvector.Vector vectorA, Pgvector.Vector vectorB)
        {
            var a = vectorA.ToArray();
            var b = vectorB.ToArray();

            if (a.Length != b.Length)
                throw new ArgumentException("Vectors must be of the same dimension.");

            float dotProduct = 0;
            float normA = 0;
            float normB = 0;

            int vectorSize = Vector<float>.Count;
            int i;
            for (i = 0; i <= a.Length - vectorSize; i += vectorSize)
            {
                var va = new Vector<float>(a, i);
                var vb = new Vector<float>(b, i);
                dotProduct += System.Numerics.Vector.Dot(va, vb);
                normA += System.Numerics.Vector.Dot(va, va);
                normB += System.Numerics.Vector.Dot(vb, vb);
            }

            for (; i < a.Length; ++i) // Handle remainder
            {
                dotProduct += a[i] * b[i];
                normA += a[i] * a[i];
                normB += b[i] * b[i];
            }

            normA = (float)Math.Sqrt(normA);
            normB = (float)Math.Sqrt(normB);

            if (normA == 0 || normB == 0)
                return 1; // Maximum dissimilarity

            return 1 - (dotProduct / (normA * normB));
        }

        /* ChatGPT said the one above is faster
         * 
        /// <summary>
        /// Warning - this is slower than Pgvector.EntityFrameworkCore.CosineDistance, which is evaluated on the database
        /// </summary>
        /// <param name="vectorA"></param>
        /// <param name="vectorB"></param>
        /// <returns></returns>
         public static float ClientEvaluatedCosineDistance(this Vector vectorA, Vector vectorB)
        {
            float[] a = vectorA.ToArray();
            float[] b = vectorB.ToArray();

            float dotProduct = 0;
            float normA = 0;
            float normB = 0;

            for (int i = 0; i < a.Length; i++)
            {
                dotProduct += a[i] * b[i];
                normA += a[i] * a[i];
                normB += b[i] * b[i];
            }

            normA = (float)Math.Sqrt(normA);
            normB = (float)Math.Sqrt(normB);

            if (normA == 0 || normB == 0)
                return 0; // Can't divide by zero, return similarity as 0 which implies orthogonal vectors.

            return 1 - (dotProduct / (normA * normB));
        }*/
    }
}
