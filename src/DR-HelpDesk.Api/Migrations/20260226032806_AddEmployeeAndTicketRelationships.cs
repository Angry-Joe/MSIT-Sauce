using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace DR_HelpDesk.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddEmployeeAndTicketRelationships : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AssignedTo",
                table: "Tickets");

            migrationBuilder.AlterColumn<string>(
                name: "CustomerEmail",
                table: "Tickets",
                type: "nvarchar(150)",
                maxLength: 150,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "nvarchar(450)");

            migrationBuilder.AddColumn<DateTime>(
                name: "AssignedAt",
                table: "Tickets",
                type: "datetime2",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "AssignedToEmployeeId",
                table: "Tickets",
                type: "nvarchar(50)",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "ContactId",
                table: "Tickets",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<Guid>(
                name: "CustomerId",
                table: "Tickets",
                type: "uniqueidentifier",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "ResolvedAt",
                table: "Tickets",
                type: "datetime2",
                nullable: true);

            migrationBuilder.CreateTable(
                name: "Employees",
                columns: table => new
                {
                    Id = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: false),
                    DisplayName = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    JobTitle = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    Department = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    Phone = table.Column<string>(type: "nvarchar(30)", maxLength: 30, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false),
                    IsOnCall = table.Column<bool>(type: "bit", nullable: false),
                    SLATier = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    LastSyncedFromEntra = table.Column<DateTime>(type: "datetime2", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: false),
                    UpdatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Employees", x => x.Id);
                });

            migrationBuilder.CreateIndex(
                name: "IX_Tickets_AssignedToEmployeeId",
                table: "Tickets",
                column: "AssignedToEmployeeId");

            migrationBuilder.CreateIndex(
                name: "IX_Tickets_ContactId",
                table: "Tickets",
                column: "ContactId");

            migrationBuilder.CreateIndex(
                name: "IX_Tickets_CustomerId",
                table: "Tickets",
                column: "CustomerId");

            migrationBuilder.AddForeignKey(
                name: "FK_Tickets_Contacts_ContactId",
                table: "Tickets",
                column: "ContactId",
                principalTable: "Contacts",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);

            migrationBuilder.AddForeignKey(
                name: "FK_Tickets_Customers_CustomerId",
                table: "Tickets",
                column: "CustomerId",
                principalTable: "Customers",
                principalColumn: "Id",
                onDelete: ReferentialAction.Restrict);

            migrationBuilder.AddForeignKey(
                name: "FK_Tickets_Employees_AssignedToEmployeeId",
                table: "Tickets",
                column: "AssignedToEmployeeId",
                principalTable: "Employees",
                principalColumn: "Id",
                onDelete: ReferentialAction.SetNull);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Tickets_Contacts_ContactId",
                table: "Tickets");

            migrationBuilder.DropForeignKey(
                name: "FK_Tickets_Customers_CustomerId",
                table: "Tickets");

            migrationBuilder.DropForeignKey(
                name: "FK_Tickets_Employees_AssignedToEmployeeId",
                table: "Tickets");

            migrationBuilder.DropTable(
                name: "Employees");

            migrationBuilder.DropIndex(
                name: "IX_Tickets_AssignedToEmployeeId",
                table: "Tickets");

            migrationBuilder.DropIndex(
                name: "IX_Tickets_ContactId",
                table: "Tickets");

            migrationBuilder.DropIndex(
                name: "IX_Tickets_CustomerId",
                table: "Tickets");

            migrationBuilder.DropColumn(
                name: "AssignedAt",
                table: "Tickets");

            migrationBuilder.DropColumn(
                name: "AssignedToEmployeeId",
                table: "Tickets");

            migrationBuilder.DropColumn(
                name: "ContactId",
                table: "Tickets");

            migrationBuilder.DropColumn(
                name: "CustomerId",
                table: "Tickets");

            migrationBuilder.DropColumn(
                name: "ResolvedAt",
                table: "Tickets");

            migrationBuilder.AlterColumn<string>(
                name: "CustomerEmail",
                table: "Tickets",
                type: "nvarchar(450)",
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "nvarchar(150)",
                oldMaxLength: 150,
                oldNullable: true);

            migrationBuilder.AddColumn<string>(
                name: "AssignedTo",
                table: "Tickets",
                type: "nvarchar(max)",
                nullable: true);
        }
    }
}
