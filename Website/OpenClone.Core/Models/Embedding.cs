using Microsoft.EntityFrameworkCore.Metadata.Internal;
using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;

namespace OpenClone.Core.Models
{
    [Microsoft.EntityFrameworkCore.Index(nameof(Text))]
    public class Embedding
    {
        [Required]
        public string Text { get; set; }
        [Column(TypeName = "vector(1536)")]
        public Pgvector.Vector? Vector { get; set; }
    }

    public class EmbeddingComparer<T>: IEqualityComparer<T> where T : Embedding, new()
    {
        public bool Equals(T x, T y)
        {
            if (ReferenceEquals(x, y)) return true;
            if (x is null) return false;
            if (y is null) return false;
            if (x.GetType() != y.GetType()) return false;
            return x.Text == y.Text; 
        }

        public int GetHashCode(T obj)
        {
            return (obj.Text != null ? obj.Text.GetHashCode() : 0);
        }
    }
}
