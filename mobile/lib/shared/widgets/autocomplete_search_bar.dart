import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/explore/domain/entities/search_suggestion.dart';
import '../../features/explore/presentation/providers/explore_provider.dart';

class AutocompleteSearchBar extends ConsumerStatefulWidget {
  final String? initialValue;
  final String hintText;
  final ValueChanged<String>? onSearchSubmitted;
  final ValueChanged<SuggestionItem>? onSuggestionSelected;
  final VoidCallback? onClear;

  const AutocompleteSearchBar({
    super.key,
    this.initialValue,
    this.hintText = 'Search businesses, services, products...',
    this.onSearchSubmitted,
    this.onSuggestionSelected,
    this.onClear,
  });

  @override
  ConsumerState<AutocompleteSearchBar> createState() => _AutocompleteSearchBarState();
}

class _AutocompleteSearchBarState extends ConsumerState<AutocompleteSearchBar> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  Timer? _debounceTimer;

  SearchSuggestionResult _suggestions = const SearchSuggestionResult();
  bool _isLoadingSuggestions = false;

  static const Color _goldColor = Color(0xFFE8B923);
  static const Color _darkCard = Color(0xFF1A1A1A);

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(covariant AutocompleteSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != null && widget.initialValue != _controller.text) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _removeOverlay();
    _debounceTimer?.cancel();
    _focusNode.removeListener(_onFocusChanged);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus && _controller.text.trim().isNotEmpty) {
      _onTextChanged(_controller.text);
    } else {
      _removeOverlay();
    }
  }

  void _onTextChanged(String text) {
    _debounceTimer?.cancel();
    if (text.trim().isEmpty) {
      _suggestions = const SearchSuggestionResult();
      _removeOverlay();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 250), () async {
      if (!mounted) return;
      setState(() {
        _isLoadingSuggestions = true;
      });

      try {
        final repo = ref.read(exploreRepositoryProvider);
        final results = await repo.getSearchSuggestions(text.trim());
        if (mounted && _focusNode.hasFocus) {
          setState(() {
            _suggestions = results;
            _isLoadingSuggestions = false;
          });
          if (results.isNotEmpty) {
            _showOverlay();
          } else {
            _removeOverlay();
          }
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _isLoadingSuggestions = false;
          });
        }
      }
    });
  }

  void _showOverlay() {
    _removeOverlay();
    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;
    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 6.0),
          child: Material(
            elevation: 12,
            borderRadius: BorderRadius.circular(16),
            color: const Color(0xFF14141A),
            shadowColor: Colors.black.withValues(alpha: 0.8),
            child: Container(
              constraints: const BoxConstraints(maxHeight: 320),
              decoration: BoxDecoration(
                color: const Color(0xFF14141A),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _goldColor.withValues(alpha: 0.3)),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  shrinkWrap: true,
                  children: [
                    if (_suggestions.businesses.isNotEmpty) ...[
                      _buildHeader('BUSINESSES'),
                      ..._suggestions.businesses.map((item) => _buildSuggestionTile(item, Icons.storefront)),
                    ],
                    if (_suggestions.categories.isNotEmpty) ...[
                      _buildHeader('CATEGORIES'),
                      ..._suggestions.categories.map((item) => _buildSuggestionTile(item, Icons.category)),
                    ],
                    if (_suggestions.products.isNotEmpty) ...[
                      _buildHeader('PRODUCTS'),
                      ..._suggestions.products.map((item) => _buildSuggestionTile(item, Icons.shopping_bag)),
                    ],
                    if (_suggestions.services.isNotEmpty) ...[
                      _buildHeader('SERVICES'),
                      ..._suggestions.services.map((item) => _buildSuggestionTile(item, Icons.build_circle)),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );

    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Widget _buildHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        title,
        style: TextStyle(
          color: _goldColor.withValues(alpha: 0.8),
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildSuggestionTile(SuggestionItem item, IconData defaultIcon) {
    return ListTile(
      dense: true,
      visualDensity: VisualDensity.compact,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: _darkCard,
          borderRadius: BorderRadius.circular(8),
        ),
        child: item.logo != null && item.logo!.isNotEmpty
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(item.logo!, fit: BoxFit.cover, errorBuilder: (_, __, ___) => Icon(defaultIcon, color: _goldColor, size: 16)),
              )
            : Icon(defaultIcon, color: _goldColor, size: 16),
      ),
      title: Text(
        item.title,
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: item.subtitle != null && item.subtitle!.isNotEmpty
          ? Text(
              item.subtitle!,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : null,
      trailing: item.price != null
          ? Text(
              '\$${item.price!.toStringAsFixed(2)}',
              style: const TextStyle(color: _goldColor, fontSize: 12, fontWeight: FontWeight.bold),
            )
          : const Icon(Icons.arrow_forward_ios, color: Colors.white24, size: 12),
      onTap: () {
        _removeOverlay();
        _focusNode.unfocus();
        if (widget.onSuggestionSelected != null) {
          widget.onSuggestionSelected!(item);
        } else if (widget.onSearchSubmitted != null) {
          _controller.text = item.title;
          widget.onSearchSubmitted!(item.title);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: _darkCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _focusNode.hasFocus ? _goldColor.withValues(alpha: 0.6) : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                style: const TextStyle(color: Colors.white),
                onChanged: _onTextChanged,
                onSubmitted: (value) {
                  _removeOverlay();
                  _focusNode.unfocus();
                  if (value.trim().isNotEmpty && widget.onSearchSubmitted != null) {
                    widget.onSearchSubmitted!(value.trim());
                  }
                },
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.4),
                    fontSize: 14,
                  ),
                  prefixIcon: _isLoadingSuggestions
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(_goldColor),
                            ),
                          ),
                        )
                      : Icon(
                          Icons.search,
                          color: Colors.white.withValues(alpha: 0.5),
                          size: 20,
                        ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear, color: Colors.white54, size: 18),
                          onPressed: () {
                            _controller.clear();
                            _removeOverlay();
                            if (widget.onClear != null) widget.onClear!();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            if (widget.onSearchSubmitted != null)
              GestureDetector(
                onTap: () {
                  _removeOverlay();
                  _focusNode.unfocus();
                  final query = _controller.text.trim();
                  widget.onSearchSubmitted!(query);
                },
                child: Container(
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _goldColor,
                    borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
                  ),
                  child: const Center(
                    child: Text(
                      'Search',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
