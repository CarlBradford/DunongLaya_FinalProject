import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

class ContactUsPage extends StatefulWidget {
  const ContactUsPage({super.key});

  @override
  State<ContactUsPage> createState() => _ContactUsPageState();
}

class _ContactUsPageState extends State<ContactUsPage> with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  
  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _messageFocus = FocusNode();
  
  bool _submitted = false;
  bool _isFormValid = false;
  String _submitButtonText = 'Send Message';
  
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _pulseController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;
  
  // Field validation states
  bool _nameValid = false;
  bool _emailValid = false;
  bool _phoneValid = false;
  bool _messageValid = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _setupFormListeners();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _scaleController.forward();
    });
    
    _pulseController.repeat(reverse: true);
  }

  void _setupFormListeners() {
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _phoneController.addListener(_validateForm);
    _messageController.addListener(_validateForm);
  }

  void _validateForm() {
    final nameValid = _nameController.text.trim().isNotEmpty && 
                      _nameController.text.trim().length >= 2;
    final emailValid = _isValidEmail(_emailController.text.trim());
    final phoneValid = _isValidPhone(_phoneController.text.trim());
    final messageValid = _messageController.text.trim().isNotEmpty && 
                         _messageController.text.trim().length >= 10;

    setState(() {
      _nameValid = nameValid;
      _emailValid = emailValid;
      _phoneValid = phoneValid;
      _messageValid = messageValid;
      _isFormValid = nameValid && emailValid && phoneValid && messageValid;
    });
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$');
    return email.isNotEmpty && emailRegex.hasMatch(email);
  }

  bool _isValidPhone(String phone) {
    final phoneRegex = RegExp(r'^\+?[\d\s\-\(\)]{10,}$');
    return phone.isNotEmpty && phoneRegex.hasMatch(phone);
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Name is required';
    }
    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!RegExp(r'^[a-zA-Z\s]+$').hasMatch(value.trim())) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!_isValidEmail(value.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Phone number is required';
    }
    if (!_isValidPhone(value.trim())) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  String? _validateMessage(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Message is required';
    }
    if (value.trim().length < 10) {
      return 'Message must be at least 10 characters';
    }
    if (value.trim().length > 500) {
      return 'Message cannot exceed 500 characters';
    }
    return null;
  }

  void _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please fix the errors above', isError: true);
      return;
    }

    setState(() {
      _submitted = true;
      _submitButtonText = 'Sending...';
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    try {
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        setState(() {
          _submitted = false;
          _submitButtonText = 'Message Sent!';
        });
        
        // Success animation
        HapticFeedback.selectionClick();
        
        // Clear form after success
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _clearForm();
            _showSnackBar('Message sent successfully!', isError: false);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _submitted = false;
          _submitButtonText = 'Send Message';
        });
        _showSnackBar('Failed to send message. Please try again.', isError: true);
      }
    }
  }

  void _clearForm() {
    setState(() {
      _nameController.clear();
      _emailController.clear();
      _phoneController.clear();
      _messageController.clear();
      _submitButtonText = 'Send Message';
      _isFormValid = false;
      _nameValid = false;
      _emailValid = false;
      _phoneValid = false;
      _messageValid = false;
    });
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: Duration(seconds: isError ? 4 : 2),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String label,
    required IconData icon,
    required String? Function(String?) validator,
    required bool isValid,
    TextInputType keyboardType = TextInputType.text,
    int minLines = 1,
    int maxLines = 1,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: !_submitted,
        keyboardType: keyboardType,
        minLines: minLines,
        maxLines: maxLines,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              icon,
              color: focusNode.hasFocus 
                  ? AppColors.primary 
                  : (isValid ? Colors.green : Colors.grey),
            ),
          ),
          suffixIcon: controller.text.isNotEmpty
              ? AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: isValid
                      ? const Icon(Icons.check_circle, color: Colors.green, key: ValueKey('valid'))
                      : const Icon(Icons.error, color: Colors.red, key: ValueKey('invalid')),
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          filled: true,
          fillColor: focusNode.hasFocus 
              ? AppColors.primary.withOpacity(0.05)
              : AppColors.onPrimary,
          labelStyle: TextStyle(
            color: focusNode.hasFocus ? AppColors.primary : Colors.grey.shade600,
          ),
        ),
        validator: validator,
        onFieldSubmitted: (_) => _moveToNextField(focusNode),
      ),
    );
  }

  void _moveToNextField(FocusNode currentFocus) {
    if (currentFocus == _nameFocus) {
      _emailFocus.requestFocus();
    } else if (currentFocus == _emailFocus) {
      _phoneFocus.requestFocus();
    } else if (currentFocus == _phoneFocus) {
      _messageFocus.requestFocus();
    } else {
      currentFocus.unfocus();
      if (_isFormValid) _submitForm();
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _pulseController.dispose();
    
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _messageController.dispose();
    
    _nameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    _messageFocus.dispose();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Contact Us',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Card(
                  elevation: 12,
                  shadowColor: AppColors.primary.withOpacity(0.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  color: AppColors.surface,
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo with pulse animation
                        AnimatedBuilder(
                          animation: _pulseAnimation,
                          builder: (context, child) {
                            return Transform.scale(
                              scale: _pulseAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.primary.withOpacity(0.1),
                                ),
                                child: Image.asset(
                                  'assets/images/the_axis_logo.png',
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 24),
                        
                        // Title
                        Text(
                          'Get in Touch',
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                            letterSpacing: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        
                        Text(
                          'We\'d love to hear from you. Send us a message!',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        Divider(
                          color: AppColors.secondary,
                          thickness: 2,
                          height: 8,
                        ),
                        const SizedBox(height: 24),
                        
                        // Contact Information
                        _buildContactInfo(),
                        const SizedBox(height: 32),
                        
                        // Form
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildTextField(
                                controller: _nameController,
                                focusNode: _nameFocus,
                                label: 'Full Name',
                                icon: Icons.person_outline,
                                validator: _validateName,
                                isValid: _nameValid,
                                inputFormatters: [
                                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]')),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                controller: _emailController,
                                focusNode: _emailFocus,
                                label: 'Email Address',
                                icon: Icons.email_outlined,
                                validator: _validateEmail,
                                isValid: _emailValid,
                                keyboardType: TextInputType.emailAddress,
                              ),
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                controller: _phoneController,
                                focusNode: _phoneFocus,
                                label: 'Phone Number',
                                icon: Icons.phone_outlined,
                                validator: _validatePhone,
                                isValid: _phoneValid,
                                keyboardType: TextInputType.phone,
                              ),
                              const SizedBox(height: 20),
                              
                              _buildTextField(
                                controller: _messageController,
                                focusNode: _messageFocus,
                                label: 'Message',
                                icon: Icons.message_outlined,
                                validator: _validateMessage,
                                isValid: _messageValid,
                                minLines: 4,
                                maxLines: 6,
                                keyboardType: TextInputType.multiline,
                              ),
                              const SizedBox(height: 32),
                              
                              // Submit Button
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _submitted ? null : (_isFormValid ? _submitForm : null),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _isFormValid 
                                        ? AppColors.primary 
                                        : Colors.grey.shade400,
                                    foregroundColor: Colors.white,
                                    elevation: _isFormValid ? 8 : 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: _submitted
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            _submitButtonText,
                                            style: GoogleFonts.poppins(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContactInfo() {
    return Column(
      children: [
        _buildContactItem(
          icon: Icons.email_outlined,
          title: 'Email',
          subtitle: 'theaxispub.alangilan@g.batstate-u.edu.ph',
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          icon: Icons.phone_outlined,
          title: 'Phone',
          subtitle: '(+63) 917-123-4567',
        ),
        const SizedBox(height: 16),
        _buildContactItem(
          icon: Icons.location_on_outlined,
          title: 'Address',
          subtitle: 'Batangas State University\nAlangilan Campus, Batangas City',
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}