import 'product.dart';

enum HelpType { overview, tutorial, examples, faq }

class HelpContent {
  static const String overview = """
Price Comparison Tool helps you find the best value when shopping by comparing the cost per unit of different products.

How it works:
1. Add products with their price, quantity, and unit
2. The app calculates price per unit for each product
3. Compare results to find the best value

Key Features:
• Compare up to 10 products at once
• Supports both simple products and multi-packs
• Pack mode for products sold in bundles (e.g., 6-pack, 12-pack)
• Calculates price per piece and price per unit
• Supports various units (ml, g, kg, pieces, etc.)
• Clear visual indicators for best value
• Edit and delete products easily
• Quick calculation explanations
""";

  static const String tutorial = """
Getting Started:

1. **Add Your First Product**
   • Tap the "Add Product" button
   • Choose between "Simple" or "Pack" mode:
     - Simple: For individual products (e.g., 500g flour)
     - Pack: For multi-packs (e.g., 6×200ml milk boxes)
   • Enter a descriptive name (e.g., "Organic Apples")
   • Input the total price you'll pay
   • For Simple: Enter total quantity and unit
   • For Pack: Enter how many items in the pack, size of each item, and unit
   • For Pack: Total quantity is automatically calculated for you!

2. **Add More Products**
   • Repeat for each product you want to compare
   • Use the same unit type for accurate comparison
   • You can add up to 10 products

3. **View Results**
   • The app automatically calculates price per unit
   • Products are sorted by value (best to worst)
   • Green highlighting shows the best deal

4. **Make Changes**
   • Tap any product to edit its details
   • Use the trash icon to delete products
   • Clear all products with the "Clear All" button
""";

  static const String milkExample = """
Example: Milk Comparison

Scenario: You want to buy milk and have two options:
• Option A: 6 boxes × 200ml each for 57 baht
• Option B: 3 boxes × 300ml each for 48 baht

How to compare:

1. **Calculate total volume for each option**
   • Option A: 6 × 200ml = 1,200ml total
   • Option B: 3 × 300ml = 900ml total

2. **Enter in the app:**
   • Product A: Name="Milk A (6×200ml)", Price=57, Quantity=1200, Unit=ml
   • Product B: Name="Milk B (3×300ml)", Price=48, Quantity=900, Unit=ml

3. **Compare the results:**
   • Product A: 57 ÷ 1200 = 0.048 baht per ml
   • Product B: 48 ÷ 900 = 0.053 baht per ml

**Result:** Product A offers better value (lower cost per ml)!

The app will highlight Product A in green as the best deal, saving you money.
""";

  static const String faq = """
Frequently Asked Questions:

**Q: Can I compare products with different units?**
A: While you can enter different units, it's most accurate to compare products using the same unit type (e.g., all in ml or all in grams).

**Q: What if I enter the wrong information?**
A: Tap on any product to edit its details, or use the trash icon to delete it and start over.

**Q: How many products can I compare at once?**
A: You can compare up to 10 products in a single comparison.

**Q: What does "price per unit" mean?**
A: Price per unit shows how much you pay for each unit of measure (e.g., per ml, per gram, per piece). Lower values mean better deals.

**Q: Can I save my comparisons?**
A: Currently, comparisons are cleared when you close the app. We recommend taking a screenshot of important results.

**Q: Why use total quantity instead of package quantity?**
A: Using total quantity (like 1200ml for 6×200ml boxes) gives you the most accurate comparison of actual value received.

**Q: What units are supported?**
A: Common units include: g, kg, ml, l, pieces, oz, lb, fl oz. You can also enter custom units.

**Q: How do I use Pack mode?**
A: Pack mode is for products sold in bundles. For example, if you buy a 6-pack of 200ml bottles for \$12:
• Switch to "Pack" mode
• Enter total price: 12
• Enter how many items in pack: 6
• Enter size of each item: 200
• Enter unit: ml
The app automatically calculates total quantity (1200ml) and shows both price per piece (\$2 per bottle) and price per unit (\$0.01 per ml).

**Q: When should I use Pack mode vs Simple mode?**
A: Use Pack mode when you want to compare:
• Multi-packs vs individual items (6-pack vs single bottles)
• Different pack sizes (6-pack vs 12-pack)
• Price per piece vs price per unit
Use Simple mode for straightforward quantity comparisons.
""";

  static List<HelpSection> getAllSections() {
    return [
      HelpSection(
        type: HelpType.overview,
        title: 'Overview',
        content: overview,
        icon: 'info',
      ),
      HelpSection(
        type: HelpType.tutorial,
        title: 'How to Use',
        content: tutorial,
        icon: 'play_arrow',
      ),
      HelpSection(
        type: HelpType.examples,
        title: 'Example: Milk Comparison',
        content: milkExample,
        icon: 'lightbulb',
      ),
      HelpSection(type: HelpType.faq, title: 'FAQ', content: faq, icon: 'help'),
    ];
  }
}

class HelpSection {
  final HelpType type;
  final String title;
  final String content;
  final String icon;

  const HelpSection({
    required this.type,
    required this.title,
    required this.content,
    required this.icon,
  });
}

class MilkComparisonExample {
  static const String explanation = """
Example: Comparing Milk Packages

Scenario: You want to buy milk and have two options:
• Option A: 6 boxes × 200ml each for 57 baht
• Option B: 3 boxes × 300ml each for 48 baht

How to compare:
1. Calculate total volume for each option
   • Option A: 6 × 200ml = 1,200ml total
   • Option B: 3 × 300ml = 900ml total

2. Enter in the app:
   • Product A: Price=57, Quantity=1200, Unit=ml
   • Product B: Price=48, Quantity=900, Unit=ml

3. Compare the results:
   • Product A: 57 ÷ 1200 = 0.048 baht per ml
   • Product B: 48 ÷ 900 = 0.053 baht per ml

Result: Product A offers better value (lower cost per ml)!
""";

  static List<Product> getExampleProducts() {
    return [
      Product(
        id: 'milk_a',
        name: 'Milk A (6×200ml)',
        price: 57.0,
        quantity: 1200.0,
        unit: 'ml',
        packSize: 6,
        individualQuantity: 200.0,
      ),
      Product(
        id: 'milk_b',
        name: 'Milk B (3×300ml)',
        price: 48.0,
        quantity: 900.0,
        unit: 'ml',
        packSize: 3,
        individualQuantity: 300.0,
      ),
    ];
  }

  static String getTutorialStep(int step) {
    switch (step) {
      case 1:
        return "Welcome! Let's learn how to compare prices using a real example.\n\nWe'll compare two milk options to find the better deal.";
      case 2:
        return "Scenario: You want to buy milk and found these options:\n• Milk A: 6 boxes × 200ml each for 57 baht\n• Milk B: 3 boxes × 300ml each for 48 baht";
      case 3:
        return "Step 1: Calculate total volume\n• Milk A: 6 × 200ml = 1,200ml total\n• Milk B: 3 × 300ml = 900ml total";
      case 4:
        return "Step 2: Add the first product\nTap 'Add Product' and enter:\n• Name: Milk A (6×200ml)\n• Price: 57\n• Quantity: 1200\n• Unit: ml";
      case 5:
        return "Step 3: Add the second product\nTap 'Add Product' again and enter:\n• Name: Milk B (3×300ml)\n• Price: 48\n• Quantity: 900\n• Unit: ml";
      case 6:
        return "Step 4: Compare results\nThe app shows:\n• Milk A: 0.048 baht/ml\n• Milk B: 0.053 baht/ml\n\nMilk A is the better deal!";
      default:
        return "Tutorial complete! You now know how to compare prices effectively.";
    }
  }
}
