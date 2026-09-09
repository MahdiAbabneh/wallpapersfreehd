import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../Layout/Home/cubit/cubit.dart';
import '../../Layout/Home/cubit/states.dart';
import '../../design/components.dart';
import '../../design/gallery_grid.dart';
import '../../design/tokens.dart';
import '../../models/BackendService.dart';
import '../../models/categories.dart';
import '../../models/content_filter.dart';
import '../../network/cache_helper.dart';


const String _recentsKey = 'recentSearches';

///Pexels filters by colour, which is the one thing Search can do that browsing
///the shelves cannot: pick a tone, or narrow words already typed.
const List<(String, Color)> _colours = <(String, Color)>[
  ('black', Color(0xFF141416)),
  ('white', Color(0xFFEDEDF0)),
  ('gray', Color(0xFF8A8A93)),
  ('blue', Color(0xFF3B7DD8)),
  ('turquoise', Color(0xFF2BB6B0)),
  ('green', Color(0xFF3E9F52)),
  ('yellow', Color(0xFFE0B93B)),
  ('orange', Color(0xFFE07A34)),
  ('red', Color(0xFFCF3B3B)),
  ('pink', Color(0xFFD870A8)),
  ('violet', Color(0xFF8A5BD6)),
  ('brown', Color(0xFF8B6444)),
];
const int _recentsLimit = 8;

/// Search.
///
/// The field, what has been looked for before, and the results all describe the
/// same state: clearing the field clears the results, and the header always
/// says what is on screen.
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
  List<String> _recents = <String>[];
  int _tab = 0;

  ///what the reader typed or tapped, shown in the field and the header
  String _label = '';

  ///what Pexels is actually asked; differs when a shelf name was tapped
  String _term = '';

  ///the colour filter, empty when none is chosen
  String _colour = '';

  @override
  void initState() {
    super.initState();
    _recents =
        CacheHelper.sharedPreferences?.getStringList(_recentsKey) ?? <String>[];
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  ///a shelf name is a label, not a search term
  String _termFor(String label) {
    for (final Collection c in kCollections) {
      if (c.name.toLowerCase() == label.toLowerCase()) return c.query;
    }
    return label;
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    ///rebuild on every keystroke so the clear button appears with the first letter
    setState(() {});
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
        _suggestions = ContentFilter.cleanWords(result
            .map((Map<String, String> e) => e['name'] ?? '')
            .where((String e) => e.isNotEmpty && e.toLowerCase() != value.trim().toLowerCase())
            .take(8)
            .toList());
      });
    });
  }

  void _remember(String label) {
    _recents
      ..removeWhere((String e) => e.toLowerCase() == label.toLowerCase())
      ..insert(0, label);
    if (_recents.length > _recentsLimit) {
      _recents = _recents.sublist(0, _recentsLimit);
    }
    CacheHelper.sharedPreferences?.setStringList(_recentsKey, _recents);
  }

  void _submit(String raw) {
    final String label = raw.trim();
    if (label.isEmpty) return;
    if (ContentFilter.blocksQuery(label)) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('This app does not show that kind of content'),
          ),
        );
      return;
    }
    HapticFeedback.selectionClick();
    _focus.unfocus();
    _controller.text = label;
    _remember(label);
    setState(() {
      _label = label;
      _term = _termFor(label);
      _suggestions = <String>[];
    });
    _run();
  }

  void _run() {
    final HomeCubit cubit = HomeCubit.get(context);
    if (_tab == 0) {
      cubit.searchImages(_term, color: _colour.isEmpty ? null : _colour);
    } else {
      ///the video endpoint has no colour filter, so the word carries it
      cubit.searchVideo(_colour.isEmpty ? _term : '$_colour $_term'.trim());
    }
  }

  ///a colour narrows what is already on screen, or starts a search of its own
  ///when the field is still empty
  void _pickColour(String name) {
    ///a search that came from a colour alone carries this placeholder word
    final bool colourOnly = _term == 'wallpaper';
    final String next = _colour == name ? '' : name;

    setState(() {
      _colour = next;
      if (next.isEmpty && colourOnly) {
        ///the colour was the whole search; letting it go empties the screen
        _label = '';
        _term = '';
      } else if (next.isNotEmpty && (_term.isEmpty || colourOnly)) {
        _label = next;
        _term = 'wallpaper';
      }
    });

    if (_term.isNotEmpty) _run();
  }

  ///an empty field means an empty screen: leaving results behind a cleared
  ///field is what made the search feel broken
  void _clear() {
    _debounce?.cancel();
    _controller.clear();
    setState(() {
      _label = '';
      _term = '';
      _suggestions = <String>[];
    });
    _focus.requestFocus();
  }

  void _clearRecents() {
    setState(() => _recents = <String>[]);
    CacheHelper.sharedPreferences?.remove(_recentsKey);
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
                  ScreenHeader(
                    eyebrow: _label.isEmpty
                        ? 'Find something exact'
                        : _resultLine(cubit, photos),
                    title: 'Search',
                  ),
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: AppSpace.xl),
                    child: TextField(
                      controller: _controller,
                      focusNode: _focus,
                      textInputAction: TextInputAction.search,
                      textCapitalization: TextCapitalization.none,
                      autocorrect: false,
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
                                icon: const Icon(Icons.close_rounded,
                                    size: 18, color: AppColors.textDim),
                                onPressed: _clear,
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
                        ///the same words, asked of the other library
                        if (_term.isNotEmpty) _run();
                      },
                    ),
                  ),
                  const SizedBox(height: AppSpace.md),
                ],
              ),
            ),
            if (_suggestions.isNotEmpty)
              _ChipRow(words: _suggestions, onPick: _submit)
            else if (_label.isEmpty && _recents.isNotEmpty)
              _ChipRow(
                words: _recents,
                onPick: _submit,
                title: 'Recent',
                onClear: _clearRecents,
              ),
            ///the shelves already live in Themes; what Search adds is colour
            _ColourRow(selected: _colour, onPick: _pickColour),
            Expanded(child: _results(cubit, state, photos)),
          ],
        );
      },
    );
  }

  ///the header doubles as the result count, so the reader always knows what
  ///they are looking at
  String _resultLine(HomeCubit cubit, bool photos) {
    final int count = photos
        ? (cubit.curatedSearchPhotos?.photos.length ?? 0)
        : (cubit.curatedSearchVideo?.videos.length ?? 0);
    final String colour = _colour.isEmpty ? '' : ' · $_colour';
    if (count == 0) return '“$_label”$colour';
    return '$count for “$_label”$colour';
  }

  Widget _results(HomeCubit cubit, HomeStates state, bool photos) {
    if (_label.isEmpty) {
      return const StatusView(
        icon: Icons.search_rounded,
        title: 'What are you looking for?',
        message: 'Search a subject, a mood or a colour.',
      );
    }
    if (state is WallpaperSearchImageLoading) return const GallerySkeleton();
    if (state is WallpaperSearchImageError) {
      return StatusView(
        icon: Icons.wifi_off_rounded,
        title: 'No connection',
        message: 'Check your network and search again.',
        action: FilledButton(onPressed: _run, child: const Text('Retry')),
      );
    }

    if (photos) {
      final model = cubit.curatedSearchPhotos;
      if (model == null || model.photos.isEmpty) return _nothing();
      return PhotoMasonry(
        photos: model.photos,
        cursor: cubit.searchPhotoCursor,
        onLoadMore: () => cubit.searchImages(null, more: true),
        onRefresh: () async => cubit.searchImages(_term),
      );
    }

    final model = cubit.curatedSearchVideo;
    if (model == null || model.videos.isEmpty) return _nothing();
    return VideoMasonry(
      videos: model.videos,
      cursor: cubit.searchVideoCursor,
      onLoadMore: () => cubit.searchVideo(null, more: true),
      onRefresh: () async => cubit.searchVideo(_term),
    );
  }

  Widget _nothing() => StatusView(
        icon: Icons.image_not_supported_outlined,
        title: 'Nothing for “$_label”',
        message: 'Try a shorter word, or pick one below.',
        action: Wrap(
          spacing: AppSpace.sm,
          children: kCollections
              .take(4)
              .map((Collection c) => ActionChip(
                    label: Text(c.name, style: AppText.label),
                    backgroundColor: AppColors.surface,
                    side: const BorderSide(color: AppColors.line),
                    onPressed: () => _submit(c.name),
                  ))
              .toList(),
        ),
      );
}

/// A scrolling row of words: suggestions, recents or popular shelves.
class _ChipRow extends StatelessWidget {
  const _ChipRow({
    required this.words,
    required this.onPick,
    this.title,
    this.onClear,
  });

  final List<String> words;
  final ValueChanged<String> onPick;
  final String? title;
  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (title != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpace.xl, 0, AppSpace.lg, AppSpace.sm),
            child: Row(
              children: <Widget>[
                Text(title!.toUpperCase(), style: AppText.eyebrow),
                const Spacer(),
                if (onClear != null)
                  Pressable(
                    onTap: onClear,
                    semanticLabel: 'Clear recent searches',
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpace.sm, vertical: 2),
                      child: Text('Clear',
                          style: AppText.eyebrow
                              .copyWith(color: AppColors.textDim)),
                    ),
                  ),
              ],
            ),
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
                padding: const EdgeInsets.symmetric(horizontal: AppSpace.lg),
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


/// The colour filter: a row of tones, one of which can be active.
class _ColourRow extends StatelessWidget {
  const _ColourRow({required this.selected, required this.onPick});

  final String selected;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(
              AppSpace.xl, 0, AppSpace.xl, AppSpace.sm),
          child: Text(
            selected.isEmpty ? 'ANY COLOUR' : selected.toUpperCase(),
            style: AppText.eyebrow.copyWith(
              color: selected.isEmpty ? AppColors.textFaint : AppColors.accent,
            ),
          ),
        ),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpace.xl),
            itemCount: _colours.length,
            separatorBuilder: (_, __) => const SizedBox(width: AppSpace.md),
            itemBuilder: (BuildContext context, int index) {
              final (String name, Color colour) = _colours[index];
              final bool active = name == selected;
              return Semantics(
                selected: active,
                button: true,
                label: name,
                child: Pressable(
                  onTap: () => onPick(name),
                  child: Center(
                    child: AnimatedContainer(
                      duration: AppDuration.fast,
                      width: active ? 34 : 30,
                      height: active ? 34 : 30,
                      decoration: BoxDecoration(
                        color: colour,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color:
                              active ? AppColors.accent : AppColors.lineStrong,
                          width: active ? 2.5 : 1,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: AppSpace.md),
      ],
    );
  }
}
