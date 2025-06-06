using Microsoft.EntityFrameworkCore;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace OpenClone.Core.Extensions
{
    public static class ModelBuilderExtensions
    {
        public static void UseSnakeCase(this ModelBuilder modelBuilder)
        {
            foreach (var entity in modelBuilder.Model.GetEntityTypes())
            {
                modelBuilder.Entity(entity.Name).ToTable(entity.GetTableName().ConvertToSnakeCase());

                foreach (var property in entity.GetProperties())
                {
                    var columnName = property.GetColumnName().ConvertToSnakeCase();
                    columnName = columnName.Replace("_q_a_", "_qa_");
                    columnName = columnName.Replace("i_p_a", "ip_a"); // IPAddress
                    property.SetColumnName(columnName);
                }
            }
        }
    }
}
