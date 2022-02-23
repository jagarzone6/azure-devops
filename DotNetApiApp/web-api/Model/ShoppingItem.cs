using System.ComponentModel.DataAnnotations;

namespace web_api.Model
{
    public class ShoppingItem
    {
        public ShoppingItem()
        {
        }
        public ShoppingItem(string Id, string Name, decimal Price, string Manufacturer)
        {
            this.Id = new Guid(Id);
            this.Name = Name;
            this.Price = Price;
            this.Manufacturer = Manufacturer;
        }
        public Guid Id { get; set; }
        [Required]
        public string? Name { get; set; }
        public decimal Price { get; set; }
        public string? Manufacturer { get; set; }
    }
}
