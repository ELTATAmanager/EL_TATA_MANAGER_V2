import 'package:shared_preferences/shared_preferences.dart';

class BrandingService {
  static const _keyNombre = 'brandNombre';
  static const _keySlogan = 'brandSlogan';
  static const _keyTelefono = 'brandTelefono';
  static const _keyDireccion = 'brandDireccion';
  static const _keyLogo = 'brandLogoPath';

  static final BrandingService instance = BrandingService._();
  BrandingService._();

  String nombre = 'EL TATA Manager';
  String slogan = 'Gestión de stock, ventas y más';
  String telefono = '';
  String direccion = '';
  String logoPath = '';

  Future<void> cargar() async {
    final prefs = await SharedPreferences.getInstance();
    nombre = prefs.getString(_keyNombre) ?? 'EL TATA Manager';
    slogan = prefs.getString(_keySlogan) ?? 'Gestión de stock, ventas y más';
    telefono = prefs.getString(_keyTelefono) ?? '';
    direccion = prefs.getString(_keyDireccion) ?? '';
    logoPath = prefs.getString(_keyLogo) ?? '';
  }

  Future<void> guardar({
    required String nombre,
    required String slogan,
    required String telefono,
    required String direccion,
    required String logoPath,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyNombre, nombre);
    await prefs.setString(_keySlogan, slogan);
    await prefs.setString(_keyTelefono, telefono);
    await prefs.setString(_keyDireccion, direccion);
    await prefs.setString(_keyLogo, logoPath);
    this.nombre = nombre;
    this.slogan = slogan;
    this.telefono = telefono;
    this.direccion = direccion;
    this.logoPath = logoPath;
  }
}
