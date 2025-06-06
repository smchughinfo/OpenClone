using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;
using OpenClone.Core.Models;
using System.Xml;
using System.Text;
using OpenClone.Core.Extensions;
using Pgvector.Npgsql;
using System.Text.Json;
using OpenClone.Services.Services.OpenAI.DTOs;
using static System.Runtime.InteropServices.JavaScript.JSType;
using System.Data;
using System.Reflection.Emit;
using OpenClone.Core.Models.Enums;


// TODO: currently all entities are in the core project but some of them could be included in only the services project. which would be the correct pattern

// this was originally under areas/identity when applicationdbcontet and identitydbcontext were seperate.
// do you lose any security by not having udner the identity area?

// https://github.com/pgvector/pgvector pgvector - this gets installed on postgres itself
// https://github.com/pgvector/pgvector-dotnet main pgvector ef instructions (use if you ever go to net 8)
// https://github.com/pgvector/pgvector-dotnet/blob/efcore-v0.1.2/README.md#entity-framework-core ef pgvector instructions for net 7
public class ApplicationDbContext
    : IdentityDbContext<ApplicationUser>
{
    public DbSet<ApplicationUser> ApplicationUser { get; set; }
    public DbSet<QuestionCategory> QuestionCategory { get; set; }
    public DbSet<Question> Question { get; set; }
    public DbSet<Answer> Answer { get; set; }
    public DbSet<Clone> Clone { get; set; }
    public DbSet<CloneSourceImage> CloneSourceImage { get; set; }
    public DbSet<GenerativeImage> GenerativeImage { get; set; }
    public DbSet<DeepFakeModeLookup> DeepFakeModeLookup { get; set; }
    public DbSet<ChatRoleLookup> ChatRoleLookup { get; set; }
    public DbSet<ChatSession> ChatSession { get; set; }

    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {

    }

    protected override void OnConfiguring(DbContextOptionsBuilder optionsBuilder)
    {
        optionsBuilder.UseLazyLoadingProxies();
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        SetupPGVector(modelBuilder);
        SetupQuestion(modelBuilder);
        SetupAnswer(modelBuilder);
        SetupGenerativeImage(modelBuilder);
        // TODO: check that cascade and no action work here
        SetupClone(modelBuilder);
        SetupApplicationUser(modelBuilder);
        modelBuilder.UseSnakeCase();
    }

    private void SetupClone(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Clone>().HasKey(c => c.Id);

        modelBuilder.Entity<Clone>().HasIndex(c => new
        {
            c.FirstName,
            c.ApplicationUserId
        }).IsUnique();

        modelBuilder.Entity<Clone>()
            .HasOne(c => c.ApplicationUser)
            .WithMany()
            .HasForeignKey(c => c.ApplicationUserId)
            //.OnDelete(DeleteBehavior.NoAction); // TODO: IMPORTANT - I DONT THINK THIS IS RIGHT. ACTUALLY I AM CHANGING IT NOW...
            .OnDelete(DeleteBehavior.Cascade);    // TODO: IMPORTANT - VERIFY THIS IS RIGHT. WHEN DELETE APPLICATION USER SHOULD DELETE CLONE ....WHICH SHOULD DELETE CLONE'S CUSTOMS QUESTIONS AND THE CLONE'S ANSWERS

        modelBuilder.Entity<Clone>()
            .HasOne(c => c.DeepFakeMode)
            .WithMany() // Assuming DeepFakeModeLookup is a lookup table and doesn't need navigation property to Clone
            .HasForeignKey(c => c.DeepFakeModeLookupId)
            .OnDelete(DeleteBehavior.Restrict);
    }

    private void SetupApplicationUser(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<ApplicationUser>()
            .HasOne(a => a.ActiveClone)
            .WithOne()
            .HasForeignKey<ApplicationUser>(a => new { a.ActiveCloneId });


        /*modelBuilder.Entity<Question>()
            .HasOne(q => q.User)
            .WithMany() // Assuming a one-to-many relationship
            .HasForeignKey(q => q.ApplicationUserId)
            .IsRequired(false);*/

        //.HasPrincipalKey<ApplicationUser>(A => A.Id);
        //.OnDelete(DeleteBehavior.Cascade);

        //modelBuilder.Entity<ApplicationUser>().ToTable("AspNetUsers");
        //   .HasDiscriminator<string>("ApplicationUser");


        /*modelBuilder.Entity<ApplicationUser>()
            .HasOne(a => a.ActiveClone)
            .WithMany()
            .OnDelete(DeleteBehavior.Cascade);*/
    }

    private void SetupQuestion(ModelBuilder modelBuilder)
    {
        modelBuilder
            .Entity<Question>()
            .HasIndex(i => i.CloneId);

        modelBuilder.Entity<Question>()
            .HasOne(q => q.clone)
            .WithMany()
            .HasForeignKey(q => q.CloneId)
            .OnDelete(DeleteBehavior.Cascade);
    }

    private void SetupAnswer(ModelBuilder modelBuilder)
    {
        SetupEmbeddingSubclass<Answer>(modelBuilder);

        modelBuilder.Entity<Answer>().HasKey(a => new
        {
            a.CloneId,
            a.QuestionId
        });
        //modelBuilder.Entity<Answer>().HasIndex(a => new { a.CloneId, a.QuestionId }).IsUnique();

        modelBuilder.Entity<Answer>()
            .HasOne(a => a.Question)
            .WithMany()
            .HasForeignKey(a => a.QuestionId);

        modelBuilder.Entity<Answer>()
            .HasOne(a => a.Clone)
            .WithMany()
            .HasForeignKey(a => a.CloneId);


        base.OnModelCreating(modelBuilder);
    }

    private void SetupChatMessage(ModelBuilder modelBuilder)
    {
        // Configure ChatMessage to ChatRoleLookup relationship
        modelBuilder.Entity<ChatMessage>()
            .HasOne(cm => cm.ChatRole) // Navigation property in ChatMessage
            .WithMany() // No navigation property in ChatRoleLookup
            .HasForeignKey(cm => cm.ChatRoleLookupId) // Foreign key in ChatMessage
            .OnDelete(DeleteBehavior.Restrict); // Prevent deletion of ChatRoleLookup when ChatMessage is deleted
    }
    private void SetupGenerativeImage(ModelBuilder modelBuilder)
    {
        SetupEmbeddingSubclass<GenerativeImage>(modelBuilder);
    }

    private void SetupPGVector(ModelBuilder modelBuilder)
    {
        // https://github.com/pgvector/pgvector-dotnet/blob/efcore-v0.1.2/README.md#entity-framework-core check the "Entity Framework Core" section for more information
        modelBuilder.HasPostgresExtension("vector");
    }

    private void SetupEmbeddingSubclass<T>(ModelBuilder modelBuilder) where T: Embedding, new()
    {
        // documentation uses fluent api. otherwise i'd set this with data annotations.

        // https://github.com/pgvector/pgvector-dotnet/blob/efcore-v0.1.2/README.md#entity-framework-core check the "Entity Framework Core" section for more information
        modelBuilder
            .Entity<T>()
            .ToTable(typeof(T).Name)
            .HasIndex(i => i.Vector)
            .HasMethod("hnsw") // ivfflat or hnsw - explanation from chatgpt: Choose IVFFlat for scalability and speed with large datasets, and HNSW for high accuracy and efficiency in high - dimensional data, adjusting based on empirical testing.
            .HasOperators("vector_cosine_ops");
    }
}