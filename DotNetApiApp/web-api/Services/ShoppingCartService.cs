using web_api.Contracts;
using web_api.Model;

namespace web_api.Services
{
    public class ShoppingCartService : IShoppingCartService
    {
        public ShoppingItem Add(ShoppingItem newItem) =>
        new ShoppingItem("ab2bd817-98cd-4cf3-a80a-53ea0cd9c200", "Test name", 1.023m, "test Manufacturer");

        public IEnumerable<ShoppingItem> GetAllItems() => new List<ShoppingItem>(){
			new ShoppingItem("ab2bd817-98cd-4cf3-a80a-53ea0cd9c200", "Test name", 1.023m, "test Manufacturer"),
			new ShoppingItem("a34fddf3-98cd-4cf3-a80a-53ea0cd9c200", "2 Test name 2", 1.023m, "2 test 2 Manufacturer"),
			new ShoppingItem("4fffddf3-98cd-4cf3-a80a-53ea0cd9c244", "3 Test name 3", 1.023m, "3 test 3 Manufacturer")
		};

        public ShoppingItem GetById(Guid id) => 
		new ShoppingItem("ab2bd817-98cd-4cf3-a80a-53ea0cd9c200", "Test name", 1.023m, "test Manufacturer");

        public void Remove(Guid id) => throw new NotImplementedException();
    }
}
