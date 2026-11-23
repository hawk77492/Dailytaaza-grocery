import 'package:flutter/material.dart';

void main() => runApp(const FreshBasketApp());

class FreshBasketApp extends StatelessWidget {
  const FreshBasketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshBasket',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF16834A)),
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int tab = 0;
  int points = 0;
  int primeMinutes = 0;
  final Map<String, int> cart = {};
  final products = const [
    ('Fresh Tomatoes', '₹30 / 500g', 30, '🍅'),
    ('Potatoes', '₹25 / 1kg', 25, '🥔'),
    ('Bananas', '₹40 / dozen', 40, '🍌'),
    ('Milk', '₹32 / 500ml', 32, '🥛'),
    ('Bread', '₹35 / pack', 35, '🍞'),
    ('Apples', '₹120 / 1kg', 120, '🍎'),
  ];

  int get subtotal {
    int total = 0;
    for (final p in products) {
      total += p.$3 * (cart[p.$1] ?? 0);
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _shop(),
      _rewards(),
      _cart(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('FreshBasket', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: Text('⭐ $points pts')),
          ),
        ],
      ),
      body: pages[tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (v) => setState(() => tab = v),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Shop'),
          NavigationDestination(icon: Icon(Icons.card_giftcard_outlined), label: 'Rewards'),
          NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), label: 'Cart'),
        ],
      ),
    );
  }

  Widget _shop() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: const Color(0xFFE7F5EC), borderRadius: BorderRadius.circular(18)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Fresh groceries, delivered locally', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          SizedBox(height: 6),
          Text('Demo app • Add products to your cart'),
        ]),
      ),
      const SizedBox(height: 16),
      const Text('Popular groceries', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ...products.map((p) => Card(
        child: ListTile(
          leading: Text(p.$4, style: const TextStyle(fontSize: 30)),
          title: Text(p.$1),
          subtitle: Text(p.$2),
          trailing: FilledButton(
            onPressed: () => setState(() => cart[p.$1] = (cart[p.$1] ?? 0) + 1),
            child: const Text('Add'),
          ),
        ),
      )),
    ],
  );

  Widget _rewards() => ListView(
    padding: const EdgeInsets.all(16),
    children: [
      Card(
        color: const Color(0xFFE7F5EC),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Points Wallet', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('$points points', style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const Text('Demo balance'),
          ]),
        ),
      ),
      const SizedBox(height: 12),
      const Text('Watch a rewarded ad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const Text('In this prototype, the button simulates a completed ad. No real ad is shown.'),
      const SizedBox(height: 8),
      FilledButton.icon(
        onPressed: () => setState(() => points += 15),
        icon: const Icon(Icons.play_circle_outline),
        label: const Text('Simulate ad completion • +15 points'),
      ),
      const Divider(height: 32),
      const Text('Prime Membership', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const Text('150 points = 1 hour Prime • 5% off eligible items • Minimum order ₹199'),
      const SizedBox(height: 8),
      FilledButton(
        onPressed: points >= 150 && primeMinutes == 0
            ? () => setState(() { points -= 150; primeMinutes = 60; })
            : null,
        child: const Text('Activate Prime (150 points)'),
      ),
      if (primeMinutes > 0) Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Text('Prime active in demo: $primeMinutes minutes'),
      ),
    ],
  );

  Widget _cart() {
    final discount = primeMinutes > 0 && subtotal >= 199 ? (subtotal * 0.05).round() : 0;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text('Your Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        if (cart.isEmpty) const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: Text('Your cart is empty. Add groceries from Shop.')),
        ),
        ...cart.entries.where((e) => e.value > 0).map((e) {
          final p = products.firstWhere((p) => p.$1 == e.key);
          return ListTile(
            title: Text(e.key),
            subtitle: Text('₹${p.$3} × ${e.value}'),
            trailing: IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              onPressed: () => setState(() {
                final next = (cart[e.key] ?? 0) - 1;
                if (next <= 0) { cart.remove(e.key); } else { cart[e.key] = next; }
              }),
            ),
          );
        }),
        const Divider(),
        _line('Subtotal', '₹$subtotal'),
        _line('Prime discount', '-₹$discount'),
        _line('Total', '₹${subtotal - discount}', bold: true),
        const SizedBox(height: 12),
        Text(subtotal < 199 ? 'Add ₹${199 - subtotal} more to reach the ₹199 minimum order.' : 'Minimum order reached.'),
        const SizedBox(height: 12),
        FilledButton(
          onPressed: subtotal >= 199 ? () => ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Demo only: checkout is not connected yet.')),
          ) : null,
          child: const Text('Continue to checkout'),
        ),
      ],
    );
  }

  Widget _line(String label, String value, {bool bold = false}) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
      Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),
    ]),
  );
}
