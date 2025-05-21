import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:stock_manager/domain/entities/product.dart';
import 'package:stock_manager/domain/repositories/product_repository.dart';

part 'product_list_event.dart';
part 'product_list_state.dart';

class ProductListBloc extends Bloc<ProductListEvent, ProductListState> {
  final ProductRepository productRepository;

  ProductListBloc(this.productRepository) : super(ProductListInitial()) {
    on<LoadProducts>(_onLoadProducts);
  }

  Future<void> _onLoadProducts(
      LoadProducts event,
      Emitter<ProductListState> emit,
      ) async {
    emit(ProductListLoading());
    try {
      final products = await productRepository.getProducts();
      emit(ProductListLoaded(products));
    } catch (e) {
      emit(ProductListError('Failed to load products'));
    }
  }
}