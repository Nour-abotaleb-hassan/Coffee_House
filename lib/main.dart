import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const coffeeBrown = Color(0xFF543A20);
const coffeeDark = Color(0xFF171614);
const caramel = Color(0xFFD09A62);
const cream = Color(0xFFF0D4B2);
const fieldColor = Color(0xFF111315);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: coffeeBrown,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: caramel,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MyApp());
}

class CoffeeProduct {
  const CoffeeProduct(this.id, this.name, this.price, this.image, this.note);
  final String id, name, image, note;
  final double price;
}

const products = <CoffeeProduct>[
  CoffeeProduct(
    'arabica',
    'Arabica',
    18,
    'assets/images/coffee.jpg',
    'Smooth premium coffee',
  ),
  CoffeeProduct(
    'robusta',
    'Robusta',
    20,
    'assets/images/cup.jpg',
    'Strong rich coffee',
  ),
  CoffeeProduct(
    'excelsa',
    'Excelsa',
    15,
    'assets/images/beans.jpg',
    'Bold with a fruity finish',
  ),
  CoffeeProduct(
    'liberica',
    'Liberica',
    12,
    'assets/images/coffee.jpg',
    'Sweet, unique aroma',
  ),
  CoffeeProduct(
    'citrus',
    'Citrus',
    12,
    'assets/images/cup.jpg',
    'Fresh orange coffee',
  ),
];

class CoffeeStore extends ChangeNotifier {
  CoffeeStore.demo() {
    cart.addAll({'robusta': 1, 'liberica': 1, 'citrus': 1});
  }
  String name = 'Shahzaib', email = '';
  final Map<String, int> cart = {};
  final Set<String> favorites = {};
  bool coupon = false;
  int get count => cart.values.fold(0, (a, b) => a + b);
  List<CoffeeProduct> get cartItems =>
      products.where((p) => cart.containsKey(p.id)).toList();
  double get subtotal =>
      cartItems.fold(0, (sum, p) => sum + p.price * cart[p.id]!);
  double get shipping => cart.isEmpty ? 0 : 6;
  double get discount => coupon ? subtotal * .1 : 0;
  double get total => subtotal + shipping - discount;
  void setUser(String fullName, String address) {
    name = fullName.trim();
    email = address.trim();
    notifyListeners();
  }

  void add(String id) {
    cart[id] = (cart[id] ?? 0) + 1;
    notifyListeners();
  }

  void minus(String id) {
    final n = cart[id] ?? 0;
    if (n <= 1) {
      cart.remove(id);
    } else {
      cart[id] = n - 1;
    }
    notifyListeners();
  }

  void remove(String id) {
    cart.remove(id);
    notifyListeners();
  }

  void favorite(String id) {
    favorites.contains(id) ? favorites.remove(id) : favorites.add(id);
    notifyListeners();
  }

  void applyCoupon() {
    coupon = true;
    notifyListeners();
  }

  void clear() {
    cart.clear();
    coupon = false;
    notifyListeners();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final store = CoffeeStore.demo();
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Coffee House',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      fontFamily: 'Roboto',
      colorScheme: ColorScheme.fromSeed(
        seedColor: caramel,
        brightness: Brightness.dark,
      ),
      scaffoldBackgroundColor: coffeeBrown,
    ),
    home: LoginPage(store: store),
  );
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, required this.store});
  final CoffeeStore store;
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final key = GlobalKey<FormState>();
  final email = TextEditingController(), password = TextEditingController();
  bool hide = true;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  void login() {
    if (!key.currentState!.validate()) return;
    final address = email.text.trim();
    final guessed = address
        .split('@')
        .first
        .split(RegExp(r'[._-]'))
        .where((s) => s.isNotEmpty)
        .map((s) => '${s[0].toUpperCase()}${s.substring(1)}')
        .join(' ');
    widget.store.setUser(
      widget.store.name == 'Shahzaib' && guessed.isNotEmpty
          ? guessed
          : widget.store.name,
      address,
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => ShopPage(store: widget.store)),
    );
  }

  @override
  Widget build(BuildContext context) => AuthShell(
    child: Form(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 50),
          const Text(
            'Welcome to Login',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 30),
          AuthField(
            controller: email,
            hint: 'E-mail Address',
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v == null || !v.contains('@')
                ? 'Enter a valid e-mail address'
                : null,
          ),
          const SizedBox(height: 12),
          AuthField(
            controller: password,
            hint: 'Password',
            obscure: hide,
            validator: (v) =>
                v == null || v.length < 4 ? 'Enter your password' : null,
            suffix: IconButton(
              onPressed: () => setState(() => hide = !hide),
              icon: Icon(
                hide ? Icons.visibility_off : Icons.visibility,
                size: 17,
                color: caramel,
              ),
            ),
          ),
          const SizedBox(height: 20),
          GoldButton(label: 'Sign in', onTap: login),
          const SizedBox(height: 58),
          const SocialButtons(),
          const SizedBox(height: 40),
          Center(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(fontSize: 13, color: Colors.white),
                children: [
                  const TextSpan(text: "Don't have an account? "),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RegisterPage(store: widget.store),
                        ),
                      ),
                      child: const Text(
                        'Register',
                        style: TextStyle(
                          color: caramel,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),
        ],
      ),
    ),
  );
}

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, required this.store});
  final CoffeeStore store;
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final key = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      password = TextEditingController(),
      confirm = TextEditingController();
  bool hide = true;
  @override
  void dispose() {
    name.dispose();
    email.dispose();
    password.dispose();
    confirm.dispose();
    super.dispose();
  }

  void register() {
    if (!key.currentState!.validate()) return;
    widget.store.setUser(name.text, email.text);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => ShopPage(store: widget.store)),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => AuthShell(
    child: Form(
      key: key,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 26),
          const Text(
            'Register your Account',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 27),
          AuthField(
            controller: name,
            hint: 'Full Name',
            validator: (v) => v == null || v.trim().length < 2
                ? 'Enter your full name'
                : null,
          ),
          const SizedBox(height: 10),
          AuthField(
            controller: email,
            hint: 'E-mail Address',
            keyboardType: TextInputType.emailAddress,
            validator: (v) => v == null || !v.contains('@')
                ? 'Enter a valid e-mail address'
                : null,
          ),
          const SizedBox(height: 10),
          AuthField(
            controller: password,
            hint: 'Password',
            obscure: hide,
            validator: (v) =>
                v == null || v.length < 4 ? 'Use at least 4 characters' : null,
            suffix: IconButton(
              onPressed: () => setState(() => hide = !hide),
              icon: Icon(
                hide ? Icons.visibility_off : Icons.visibility,
                size: 17,
                color: caramel,
              ),
            ),
          ),
          const SizedBox(height: 10),
          AuthField(
            controller: confirm,
            hint: 'Confirm Password',
            obscure: true,
            validator: (v) =>
                v != password.text ? 'Passwords do not match' : null,
          ),
          const SizedBox(height: 18),
          GoldButton(label: 'Register', onTap: register),
          const SizedBox(height: 36),
          const SocialButtons(),
          const SizedBox(height: 15),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Already have an account? Sign in',
                style: TextStyle(color: cream, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class AuthShell extends StatelessWidget {
  const AuthShell({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: coffeeDark,
    body: SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 285,
            child: Image.asset(
              'assets/images/coffee_beans.png',
              fit: BoxFit.cover,
              alignment: Alignment.bottomCenter,
            ),
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    coffeeDark,
                    coffeeDark.withValues(alpha: .98),
                    coffeeDark.withValues(alpha: .70),
                    coffeeDark.withValues(alpha: .30),
                  ],
                ),
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight:
                    MediaQuery.sizeOf(context).height -
                    MediaQuery.paddingOf(context).vertical,
              ),
              child: Center(child: child),
            ),
          ),
        ],
      ),
    ),
  );
}

class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.controller,
    required this.hint,
    this.validator,
    this.keyboardType,
    this.obscure = false,
    this.suffix,
  });
  final TextEditingController controller;
  final String hint;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscure;
  final Widget? suffix;
  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    obscureText: obscure,
    validator: validator,
    style: const TextStyle(fontSize: 13, color: Colors.white),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF777777), fontSize: 12),
      filled: true,
      fillColor: fieldColor.withValues(alpha: .94),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
      suffixIcon: suffix,
      errorStyle: const TextStyle(fontSize: 10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(9),
        borderSide: const BorderSide(color: caramel),
      ),
    ),
  );
}

class GoldButton extends StatelessWidget {
  const GoldButton({super.key, required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 48,
    child: ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: caramel,
        foregroundColor: coffeeBrown,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
      ),
    ),
  );
}

class SocialButtons extends StatelessWidget {
  const SocialButtons({super.key});
  @override
  Widget build(BuildContext context) => Row(
    children: [
      _SocialButton(label: 'f'),
      const SizedBox(width: 12),
      _SocialButton(label: 'G'),
      const SizedBox(width: 12),
      _SocialButton(label: '♥'),
    ],
  );
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.label});
  final String label;
  @override
  Widget build(BuildContext context) => Expanded(
    child: SizedBox(
      height: 42,
      child: ElevatedButton(
        onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Social sign-in is a UI demo')),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF101214),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ),
    ),
  );
}

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, required this.store});
  final CoffeeStore store;
  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> {
  int tab = 0;
  void signOut() => Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => LoginPage(store: widget.store)),
    (_) => false,
  );
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: coffeeBrown,
    body: SafeArea(
      child: switch (tab) {
        0 => HomeContent(key: const ValueKey('home'), store: widget.store),
        1 => CartContent(key: const ValueKey('cart'), store: widget.store),
        2 => FavoritesContent(
          key: const ValueKey('favorites'),
          store: widget.store,
        ),
        _ => ProfileContent(
          key: const ValueKey('profile'),
          store: widget.store,
          onSignOut: signOut,
        ),
      },
    ),
    bottomNavigationBar: ShopNav(
      store: widget.store,
      selected: tab,
      onSelect: (value) => setState(() => tab = value),
    ),
  );
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key, required this.store});
  final CoffeeStore store;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(12, 7, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: caramel,
                foregroundColor: coffeeBrown,
                child: const Icon(Icons.person, size: 20),
              ),
              const SizedBox(width: 9),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Text(
                    'Good Morning!',
                    style: TextStyle(fontSize: 11, color: cream),
                  ),
                ],
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.search, size: 20),
              ),
              IconButton(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('You’re all caught up!')),
                ),
                icon: const Icon(Icons.notifications_none, size: 20),
              ),
            ],
          ),
          const SizedBox(height: 13),
          const PromoCard(),
          const SizedBox(height: 16),
          GridView.builder(
            itemCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 11,
              mainAxisSpacing: 11,
              childAspectRatio: 1.05,
            ),
            itemBuilder: (context, i) =>
                ProductCard(product: products[i], store: store),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('These are today’s popular coffees'),
                ),
              ),
              child: const Text(
                'View all',
                style: TextStyle(color: cream, fontSize: 11),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class PromoCard extends StatelessWidget {
  const PromoCard({super.key});
  @override
  Widget build(BuildContext context) => Container(
    height: 108,
    clipBehavior: Clip.antiAlias,
    decoration: BoxDecoration(
      color: caramel,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Stack(
      children: [
        Positioned(
          right: 0,
          top: 0,
          bottom: 0,
          width: 150,
          child: Image.asset('assets/images/cup.jpg', fit: BoxFit.cover),
        ),
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  caramel,
                  caramel.withValues(alpha: .96),
                  caramel.withValues(alpha: .08),
                ],
                stops: const [0, .54, 1],
              ),
            ),
          ),
        ),
        const Positioned(
          left: 12,
          top: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Get 20% Discount',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
              ),
              SizedBox(height: 4),
              Text(
                'On your First Order!',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
              ),
            ],
          ),
        ),
        const Positioned(
          right: 18,
          top: 19,
          child: Icon(Icons.coffee, color: cream, size: 25),
        ),
      ],
    ),
  );
}

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.store});
  final CoffeeProduct product;
  final CoffeeStore store;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => Container(
      padding: const EdgeInsets.fromLTRB(8, 7, 8, 6),
      decoration: BoxDecoration(
        color: caramel,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(7),
                    child: Image.asset(product.image, fit: BoxFit.cover),
                  ),
                ),
                Positioned(
                  right: 4,
                  top: 4,
                  child: InkWell(
                    onTap: () => store.favorite(product.id),
                    child: Icon(
                      store.favorites.contains(product.id)
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: store.favorites.contains(product.id)
                          ? Colors.redAccent
                          : Colors.white,
                      size: 16,
                    ),
                  ),
                ),
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: InkWell(
                    onTap: () {
                      store.add(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('${product.name} added to cart'),
                          duration: const Duration(milliseconds: 900),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: const CircleAvatar(
                      radius: 13,
                      backgroundColor: coffeeBrown,
                      child: Icon(Icons.add, size: 17, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                '\$${product.price.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          Text(
            product.note,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 8, color: Color(0xFF392716)),
          ),
        ],
      ),
    ),
  );
}

class ShopNav extends StatelessWidget {
  const ShopNav({
    super.key,
    required this.store,
    required this.selected,
    required this.onSelect,
  });
  final CoffeeStore store;
  final int selected;
  final ValueChanged<int> onSelect;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => Container(
      color: caramel,
      height: 66,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _NavItem(
            icon: Icons.home_outlined,
            index: 0,
            selected: selected == 0,
            onTap: onSelect,
          ),
          _NavItem(
            icon: Icons.shopping_cart_outlined,
            index: 1,
            selected: selected == 1,
            onTap: onSelect,
            badge: store.count,
          ),
          _NavItem(
            icon: Icons.favorite_border,
            index: 2,
            selected: selected == 2,
            onTap: onSelect,
          ),
          _NavItem(
            icon: Icons.person_outline,
            index: 3,
            selected: selected == 3,
            onTap: onSelect,
          ),
        ],
      ),
    ),
  );
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.index,
    required this.selected,
    required this.onTap,
    this.badge = 0,
  });
  final IconData icon;
  final int index;
  final bool selected;
  final int badge;
  final ValueChanged<int> onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: () => onTap(index),
    borderRadius: BorderRadius.circular(24),
    child: SizedBox(
      width: 58,
      child: Center(
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            CircleAvatar(
              radius: selected ? 21 : 19,
              backgroundColor: selected ? coffeeBrown : Colors.transparent,
              foregroundColor: selected ? cream : coffeeBrown,
              child: Icon(icon, size: 20),
            ),
            if (badge > 0)
              Positioned(
                right: -6,
                top: -5,
                child: Container(
                  width: 17,
                  height: 17,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        fontSize: 9,
                        color: coffeeBrown,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class CartContent extends StatefulWidget {
  const CartContent({super.key, required this.store});
  final CoffeeStore store;
  @override
  State<CartContent> createState() => _CartContentState();
}

class _CartContentState extends State<CartContent> {
  final couponText = TextEditingController();
  @override
  void dispose() {
    couponText.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: widget.store,
    builder: (context, _) => SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(13, 7, 13, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.arrow_back, size: 19),
              ),
              const Spacer(),
              const Text(
                'Cart',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_border, size: 19),
              ),
            ],
          ),
          const SizedBox(height: 3),
          const Text(
            'My Order',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 14),
          if (widget.store.cartItems.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 55),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.shopping_bag_outlined, size: 48, color: cream),
                    SizedBox(height: 12),
                    Text('Your cart is empty', style: TextStyle(color: cream)),
                  ],
                ),
              ),
            )
          else
            ...widget.store.cartItems.map(
              (p) => CartRow(product: p, store: widget.store),
            ),
          const SizedBox(height: 8),
          CouponRow(
            controller: couponText,
            onApply: () {
              if (couponText.text.trim().toUpperCase() == 'COFFEE10') {
                widget.store.applyCoupon();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('10% discount applied')),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Try coupon code COFFEE10')),
                );
              }
            },
          ),
          const SizedBox(height: 10),
          OrderSummary(store: widget.store),
          const SizedBox(height: 5),
          Center(
            child: TextButton(
              onPressed: widget.store.cart.isEmpty
                  ? null
                  : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Your coffee order is on its way!'),
                        ),
                      );
                      widget.store.clear();
                    },
              child: const Text(
                'Finalize Order',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class CartRow extends StatelessWidget {
  const CartRow({super.key, required this.product, required this.store});
  final CoffeeProduct product;
  final CoffeeStore store;
  @override
  Widget build(BuildContext context) => Container(
    height: 62,
    margin: const EdgeInsets.only(bottom: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
    decoration: BoxDecoration(
      color: caramel,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(
            product.image,
            width: 43,
            height: 43,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                product.name,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '\$${product.price.toStringAsFixed(0)}',
                style: const TextStyle(fontSize: 9),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => store.minus(product.id),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 30),
          icon: const Icon(Icons.remove_circle, size: 17, color: coffeeBrown),
        ),
        Text('${store.cart[product.id]}', style: const TextStyle(fontSize: 11)),
        IconButton(
          onPressed: () => store.add(product.id),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 30),
          icon: const Icon(Icons.add_circle, size: 17, color: coffeeBrown),
        ),
        IconButton(
          onPressed: () => store.remove(product.id),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 23),
          icon: const Icon(Icons.delete_outline, size: 15, color: coffeeBrown),
        ),
      ],
    ),
  );
}

class CouponRow extends StatelessWidget {
  const CouponRow({super.key, required this.controller, required this.onApply});
  final TextEditingController controller;
  final VoidCallback onApply;
  @override
  Widget build(BuildContext context) => Container(
    height: 42,
    padding: const EdgeInsets.only(left: 9),
    decoration: BoxDecoration(
      color: caramel,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            style: const TextStyle(fontSize: 10, color: coffeeBrown),
            decoration: const InputDecoration(
              border: InputBorder.none,
              hintText: 'Enter Coupon Code Here',
              hintStyle: TextStyle(fontSize: 9, color: coffeeBrown),
            ),
          ),
        ),
        TextButton(
          onPressed: onApply,
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFFB17B46),
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.horizontal(right: Radius.circular(8)),
            ),
          ),
          child: const Text('Apply', style: TextStyle(fontSize: 10)),
        ),
      ],
    ),
  );
}

class OrderSummary extends StatelessWidget {
  const OrderSummary({super.key, required this.store});
  final CoffeeStore store;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(10, 8, 10, 7),
    decoration: BoxDecoration(
      color: caramel,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Column(
      children: [
        SummaryLine(
          label: 'Sub-total',
          value: '\$${store.subtotal.toStringAsFixed(0)}',
        ),
        SummaryLine(
          label: 'Shipping',
          value: '\$${store.shipping.toStringAsFixed(0)}',
        ),
        if (store.discount > 0)
          SummaryLine(
            label: 'Coupon (10%)',
            value: '-\$${store.discount.toStringAsFixed(0)}',
          ),
        const Divider(color: Color(0x557B512D), height: 9),
        SummaryLine(
          label: 'Total',
          value: '\$${store.total.toStringAsFixed(0)}',
          bold: true,
        ),
      ],
    ),
  );
}

class SummaryLine extends StatelessWidget {
  const SummaryLine({
    super.key,
    required this.label,
    required this.value,
    this.bold = false,
  });
  final String label, value;
  final bool bold;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 10,
            fontWeight: bold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
      ],
    ),
  );
}

class FavoritesContent extends StatelessWidget {
  const FavoritesContent({super.key, required this.store});
  final CoffeeStore store;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) {
      final saved = products
          .where((p) => store.favorites.contains(p.id))
          .toList();
      return Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 15),
            const Text(
              'Favorites',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 14),
            if (saved.isEmpty)
              const Text(
                'Tap the heart on a coffee to save it here.',
                style: TextStyle(color: cream, fontSize: 12),
              )
            else
              ...saved.map(
                (p) => Card(
                  color: caramel,
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: Image.asset(
                        p.image,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(p.name),
                    subtitle: Text('\$${p.price.toStringAsFixed(0)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_shopping_cart),
                      onPressed: () => store.add(p.id),
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
    },
  );
}

class ProfileContent extends StatelessWidget {
  const ProfileContent({
    super.key,
    required this.store,
    required this.onSignOut,
  });
  final CoffeeStore store;
  final VoidCallback onSignOut;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: store,
    builder: (context, _) => Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          const Text(
            'Profile',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 28),
          Row(
            children: [
              const CircleAvatar(
                radius: 30,
                backgroundColor: caramel,
                foregroundColor: coffeeBrown,
                child: Icon(Icons.person, size: 30),
              ),
              const SizedBox(width: 14),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    store.name,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    store.email,
                    style: const TextStyle(fontSize: 11, color: cream),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 25),
          const ListTile(
            leading: Icon(Icons.receipt_long_outlined, color: cream),
            title: Text('My orders', style: TextStyle(fontSize: 13)),
            trailing: Icon(Icons.chevron_right),
          ),
          const ListTile(
            leading: Icon(Icons.location_on_outlined, color: cream),
            title: Text('Delivery address', style: TextStyle(fontSize: 13)),
            trailing: Icon(Icons.chevron_right),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onSignOut,
              icon: const Icon(Icons.logout),
              label: const Text('Sign out'),
              style: OutlinedButton.styleFrom(
                foregroundColor: cream,
                side: const BorderSide(color: caramel),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}
