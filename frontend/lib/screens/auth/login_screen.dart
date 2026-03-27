import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_surfaces.dart';
import '../../widgets/responsive_layout.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  AppRole _selectedRole = AppRole.patient;
  bool _isLoading = false;

  void _login() async {
    setState(() => _isLoading = true);
    final success = await context.read<AuthProvider>().login(
      _emailController.text,
      _passwordController.text,
      _selectedRole,
    );
    setState(() => _isLoading = false);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login failed. Please enter valid credentials.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = ResponsiveLayout.pageHorizontalPadding(context);
    final isTablet = ResponsiveLayout.isTablet(context);

    return Scaffold(
      body: GradientPageBackground(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(horizontalPadding, 22, horizontalPadding, 22),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 860),
              child: isTablet
                  ? Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 20),
                            child: _buildHero(context, alignStart: true),
                          ),
                        ),
                        Expanded(child: _buildFormCard(context)),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHero(context),
                        const SizedBox(height: 18),
                        _buildFormCard(context),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context, {bool alignStart = false}) {
    final textAlign = alignStart ? TextAlign.left : TextAlign.center;
    final crossAxis = alignStart ? CrossAxisAlignment.start : CrossAxisAlignment.center;

    return Column(
      crossAxisAlignment: crossAxis,
      children: [
        Image.asset('assets/images/biological_heart.png', height: 108),
        const SizedBox(height: 16),
        Text(
          'Cardiac',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 8),
        Text(
          'Modern cardiac intelligence for faster patient insights and safer interventions.',
          textAlign: textAlign,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).hintColor),
        ),
      ],
    );
  }

  Widget _buildFormCard(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SegmentedButton<AppRole>(
            segments: const [
              ButtonSegment(value: AppRole.patient, label: Text('Patient')),
              ButtonSegment(value: AppRole.doctor, label: Text('Doctor')),
            ],
            selected: {_selectedRole},
            onSelectionChanged: (Set<AppRole> newSelection) {
              setState(() {
                _selectedRole = newSelection.first;
                if (_selectedRole == AppRole.doctor) {
                  _emailController.text = 'doctor@cardio.ai';
                } else {
                  _emailController.text = 'patient@cardio.ai';
                }
              });
            },
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              prefixIcon: Icon(Icons.lock_outline_rounded),
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 52,
            child: FilledButton(
              onPressed: _isLoading ? null : _login,
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white),
                    )
                  : const Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
