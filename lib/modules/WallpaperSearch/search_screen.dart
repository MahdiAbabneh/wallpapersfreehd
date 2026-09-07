import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Compouents/constant_empty.dart';
import '../../Layout/Home/cubit/cubit.dart';
import '../../Layout/Home/cubit/states.dart';
import '../../design/components.dart';
import '../../design/gallery_grid.dart';
import '../../design/tokens.dart';
import '../../models/BackendService.dart';

///words the app will not look up
const List<String> _blocked = <String>['sex', 'gay', 'ass', 'boobs', 'nude'];

/// Search: one field, live suggestions, and the same gallery underneath.
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();
  Timer? _debounce;
  List<String> _suggestions = <String>[];
  int _tab = 0;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    if (value.trim().length < 3) {
      if (_suggestions.isNotEmpty) setState(() => _suggestions = <String>[]);
      return;
    }
    ///one request per pause in typing, not one per keystroke
    _debounce = Timer(const Duration(milliseconds: 320), () async {
      final List<Map<String, String>> result =
          await BackendService.getSuggestions(value.trim());
      if (!mounted) return;
      setState(() {
        _suggestions = result
            .map((Map<String, String> e) => e['name'] ?? '')
            .where((String e) => e.isNotEmpty)
            .take(8)
            .toList();
      });
    });
  }

  void _submit(String raw) {
    final String value = raw.trim().toLowerCase();
    if (value.isEmpty) return;
    if (_blocked.contains(value)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(content: Text('That word cannot be searched')),
        );
      return;
    }
    _focus.unfocus();
    _controller.text = value;
    setState(() {
      _query = value;
      _suggestions = <String>[];
    });
    final HomeCubit cubit = HomeCubit.get(context);
    if (_tab == 0) {
      cubit.searchImages(value);
    } else {
      cubit.searchVideo(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeStates>(
      builder: (BuildContext context, HomeStates state) {
        final HomeCubit cubit = HomeCubit.get(context);
        final bool photos = _tab == 0;

        return Column(
          children: <Widget>[
            SafeArea(
              bottom: false,
              child: Column(
                children: <Widget>[
                  const ScreenHeader(
                    eyebrow: 'Find something exact',
                    title: 'Search',
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      textInputAction: TextInputAction.search,
                      style: AppText.body,
                      cursorColor: AppColors.accent,
                      onChanged: _onChanged,
                      onSubmitted: _submit,
                      decoration: InputDecoration(
                        hintText: photos
                            ? 'Mountains, neon, minimal…'
                            : 'Waves, city lights, loops…',
                        prefixIcon: const Icon(Icons.search_rounded,
                            color: AppColors.textFaint, size: 20),
                        suffixIcon: _controller.text.isEmpty
                            ? null
                            : IconButton(
                                tooltip: 'Clear',
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  _controller.clear();
                                  setState(() => _suggestions = <String>[]);
                                },
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                    child: SegmentedTabs(
                      labels: const <String>['Photos', 'Videos'],
                      icons: const <IconData>[
                        Icons.image_outlined,
                        Icons.play_circle_outline_rounded,
                      ],
                      index: _tab,
                      onChanged: (int i) {
                        setState(() => _tab = i);
                        if (_query.isNotEmpty) _submit(_query);
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                ],
              ),
            ),
            if (_suggestions.isNotEmpty)
              _SuggestionRow(words: _suggestions, onPick: _submit)
            else if (_query.isEmpty)
              _SuggestionRow(
                words: categoryImages.take(8).toList(),
                onPick: _submit,
                title: 'Popular',
              ),
            Expanded(
              child: _results(cubit, state, photos),
            ),
          ],
        );
      },
    );
  }

  Widget _results(HomeCubit cubit, HomeStates state, bool photos) {
    if (_query.isEmpty) {
      return const StatusView(
        icon: Icons.search_rounded,
        title: 'What are you looking for?',
        message: 'Search a subject, a mood or a colour.',
      );
    }
    if (state is WallpaperSearchImageLoading) return const GallerySkeleton();

    if (photos) {
      final model = cubit.curatedSearchPhotos;
      if (model == null || model.photos.isEmpty) {
        return StatusView(
          icon: Icons.image_not_supported_outlined,
          title: 'Nothing for “$_query”',
          message: 'Try a different word.',
        );
      }
      return PhotoMasonry(
        photos: model.photos,
        cursor: cubit.searchPhotoCursor,
        onLoadMore: () => cubit.searchImages(null, more: true),
        onRefresh: () async => cubit.searchImages(_query),
      );
    }

    final model = cubit.curatedSearchVideo;
    if (model == null || model.videos.isEmpty) {
      return StatusView(
        icon: Icons.videocam_off_outlined,
        title: 'Nothing for “$_query”',
        message: 'Try a different word.',
      );
    }
    return VideoMasonry(
      videos: model.videos,
      cursor: cubit.searchVideoCursor,
      onLoadMore: () => cubit.searchVideo(null, more: true),
      onRefresh: () async => cubit.searchVideo(_query),
    );
  }
}

class _SuggestionRow extends StatelessWidget {
  const _SuggestionRow({required this.words, required this.onPick, this.title});

  final List<String> words;
  final ValueChanged<String> onPick;
  final String? title;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.xl, 0, AppSpace.xl, AppSpace.sm),
            child: Text(title!.toUpperCase(), style: AppText.eyebrow),
          ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
            itemCount: words.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpace.sm),
            itemBuilder: (BuildContext context, int index) => Pressable(
              onTap: () => onPick(words[index]),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpace.lg),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: AppRadius.chip,
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(words[index], style: AppText.label),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpace.md),
      ],
    );
  }
}
