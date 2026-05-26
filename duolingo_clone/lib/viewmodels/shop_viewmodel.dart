import '../core/base_viewmodel.dart';
import '../core/service_locator.dart';
import '../models/shop_product.dart';
import '../models/user_profile.dart';
import '../repositories/shop_repository.dart';
import '../repositories/user_repository.dart';

/// ViewModel responsable de exponer el estado de la pantalla de tienda.
///
/// Esta clase consume el repositorio mock de tienda para mantener la UI desacoplada de la
/// fuente de datos y centraliza tanto el saldo de gemas como la lista de productos.
class ShopViewModel extends BaseViewModel {
  /// Crea la ViewModel de la tienda con repositorios opcionales inyectados.
  ///
  /// Si no se proporcionan, se usan las instancias registradas en [ServiceLocator].
  ShopViewModel({MockShopRepository? shopRepository, MockUserRepository? userRepository})
      : _shopRepository = shopRepository ?? ServiceLocator.shopRepository,
        _userRepository = userRepository ?? ServiceLocator.userRepository;

  final MockShopRepository _shopRepository;
  final MockUserRepository _userRepository;

  UserProfile? _profile;
  List<ShopProduct> _specialOffers = const [];
  List<ShopProduct> _streakProtectors = const [];
  List<ShopProduct> _promoCodeOffers = const [];

  /// Perfil del usuario usado para mostrar el total de gemas.
  UserProfile? get profile => _profile;

  /// Total de gemas del usuario en formato listo para la UI.
  String get gemsTotalLabel => _profile == null ? '...' : '${_profile!.gems}';

  /// Lista de ofertas especiales de la tienda.
  List<ShopProduct> get specialOffers => _specialOffers;

  /// Lista de productos de protectores de racha.
  List<ShopProduct> get streakProtectors => _streakProtectors;

  /// Lista de tarjetas de codigo promocional.
  List<ShopProduct> get promoCodeOffers => _promoCodeOffers;

  /// Titulo de la primera seccion de la tienda.
  String get specialOffersTitle => 'Ofertas especiales';

  /// Titulo de la segunda seccion de la tienda.
  String get streakProtectorsTitle => 'Protectores de racha';

  /// Titulo de la tercera seccion de la tienda.
  String get promoCodeTitle => 'Código promocional';

  /// Texto explicativo para la compra de protectores de racha.
  String get streakProtectorsSubtitle => 'Compra protectores por días para no perder tu progreso.';

  /// Carga el contenido de la tienda y notifica a la UI cuando termina.
  Future<void> loadShopData() async {
    setLoading(true);

    try {
      _profile = await _userRepository.getUserProfile();
      _specialOffers = await _shopRepository.getSpecialOffers();
      _streakProtectors = await _shopRepository.getStreakProtectors();
      _promoCodeOffers = await _shopRepository.getPromoCodeOffers();
      setSuccess();
    } catch (error) {
      setError('No se pudo cargar la tienda.');
    }
  }
}