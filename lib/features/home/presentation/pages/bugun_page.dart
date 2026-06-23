import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:real_beauty_ai/features/routine/domain/routine_engine.dart';
import 'package:real_beauty_ai/features/routine/domain/routine_step.dart';
import 'package:real_beauty_ai/services/local_store.dart';

class BugunScreen extends StatefulWidget {
  const BugunScreen({super.key});

  @override
  State<BugunScreen> createState() => _BugunScreenState();
}

class _BugunScreenState extends State<BugunScreen>
    with WidgetsBindingObserver {
  final Set<String> _done = {};

  // Derived from stored history — no mock generators.
  late Map<String, bool> _streaks;
  late Map<String, double> _dailyProgress;

  // Tracks which day's tasks are loaded into _done to detect midnight rollover.
  String _loadedForDay = '';

  late List<RoutineStep> _morning;
  late List<RoutineStep> _evening;

  int get _total => _morning.length + _evening.length;
  int get _doneCount => _done.length;

  void _buildRoutine() {
    final profile = LocalStore.instance.getSkinProfile();
    if (profile == null) {
      _morning = [];
      _evening = [];
      return;
    }
    final concerns = profile.additionalBlocks
        .map((b) => b['code'] ?? '')
        .where((c) => c.isNotEmpty)
        .toSet();
    final routine = RoutineEngine.generate(
      skinType: profile.skinType,
      concerns: concerns,
      date: DateTime.now(),
    );
    _morning = routine.morning;
    _evening = routine.evening;
  }

  String get _todayKey => LocalStore.dateKey(DateTime.now());

  int get _currentStreak {
    final today = DateTime.now();
    int streak = 0;
    if (_streaks[_todayKey] == true) streak++;
    for (int i = 1; i <= 365; i++) {
      final d = today.subtract(Duration(days: i));
      if (_streaks[LocalStore.dateKey(d)] == true) {
        streak++;
      } else {
        break;
      }
    }
    return streak;
  }

  // ── Lifecycle ─────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadToday();
    _loadHistory();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // Detect midnight rollover: if user keeps app open past midnight, refresh.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _loadedForDay != _todayKey) {
      setState(() {
        _loadToday();
        _loadHistory();
      });
    }
  }

  // ── Storage reads ─────────────────────────────────────────────

  void _loadToday() {
    _buildRoutine();
    _loadedForDay = _todayKey;
    final saved = LocalStore.instance.getRoutine(_todayKey);
    _done.clear();
    for (final e in saved.entries) {
      if (e.value) _done.add(e.key);
    }
  }

  void _loadHistory() {
    _streaks = LocalStore.instance.getStreaks(_total);
    _dailyProgress = LocalStore.instance.getDailyProgress(_total);
    // Reflect today's in-progress state in the maps.
    final ratio = _total > 0 ? _doneCount / _total : 0.0;
    _streaks[_todayKey] = _doneCount == _total && _total > 0;
    _dailyProgress[_todayKey] = ratio;
  }

  // ── Task toggle ───────────────────────────────────────────────

  void _toggleTask(String k) {
    HapticFeedback.selectionClick();
    final nowDone = !_done.contains(k);
    if (nowDone) {
      _done.add(k);
    } else {
      _done.remove(k);
    }
    // Write to disk off the build path — fire and forget.
    LocalStore.instance.setTaskDone(_todayKey, k, nowDone);
    // Update streak/progress maps for today.
    final ratio = _total > 0 ? _doneCount / _total : 0.0;
    _streaks[_todayKey] = _doneCount == _total && _total > 0;
    _dailyProgress[_todayKey] = ratio;
    setState(() {});
  }

  void _showStreakCalendar() {
    HapticFeedback.mediumImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _StreakCalendarSheet(
        streaks: Map.unmodifiable(_streaks),
        currentStreak: _currentStreak,
        dateKeyFn: LocalStore.dateKey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final now = DateTime.now();
    final todayProgress = _total > 0 ? _doneCount / _total : 0.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F2FC),
      body: Stack(
        children: [
          // Static background — const avoids rebuild cost on task toggles.
          const _BugunBackground(),
          _BugunSunGlow(screenWidth: MediaQuery.of(context).size.width),
          CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(child: SizedBox(height: topPad + 14)),
              // ── Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Bugun',
                                style: GoogleFonts.nunito(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF4A3C90),
                                  letterSpacing: -0.5,
                                ),
                              ).animate(key: const ValueKey('hdr_title'))
                                  .fadeIn(duration: 350.ms),
                              Text(
                                '$_doneCount / $_total vazifa',
                                style: GoogleFonts.nunito(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: const Color(0xFF7060AA),
                                ),
                              ).animate(key: const ValueKey('hdr_sub'))
                                  .fadeIn(duration: 300.ms),
                            ],
                          ),
                          const Spacer(),
                          _GoalBadge(done: _doneCount, total: _total),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Progress bar
                      Row(
                        children: [
                          Expanded(
                            child: TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 600),
                              curve: Curves.easeOut,
                              tween: Tween(begin: 0.0, end: todayProgress),
                              builder: (_, v, _) => ClipRRect(
                                borderRadius: BorderRadius.circular(999),
                                child: LinearProgressIndicator(
                                  value: v,
                                  backgroundColor: const Color(0xFFDDD9F0),
                                  valueColor: AlwaysStoppedAnimation(
                                    todayProgress >= 1.0
                                        ? const Color(0xFF4CAF50)
                                        : const Color(0xFF7060AA),
                                  ),
                                  minHeight: 6,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            '${(todayProgress * 100).round()}%',
                            style: GoogleFonts.nunito(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: todayProgress >= 1.0
                                  ? const Color(0xFF4CAF50)
                                  : const Color(0xFF7060AA),
                            ),
                          ),
                        ],
                      ).animate(key: const ValueKey('hdr_progress'))
                          .fadeIn(delay: 80.ms),
                    ],
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 12)),
              // ── Week strip ──
              SliverToBoxAdapter(
                child: GestureDetector(
                  onTap: _showStreakCalendar,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _WeekStrip(
                      today: now,
                      streaks: _streaks,
                      dailyProgress: _dailyProgress,
                      todayProgress: todayProgress,
                      dateKeyFn: LocalStore.dateKey,
                    ),
                  ),
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 14)),
              // ── Task sheet ──
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFFF5F2FC),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(28)),
                  ),
                  child: LocalStore.instance.getSkinProfile() == null
                      ? _NoProfileCta(onTap: () => context.push('/quiz'))
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _SectionHeader(
                              svgAsset: 'assets/icons/sun.svg',
                              iconColor: const Color(0xFFE8A040),
                              text: 'Ertalab',
                              doneCount: _morning
                                  .where((s) => _done.contains(s.id))
                                  .length,
                              total: _morning.length,
                            ),
                            ..._morning.asMap().entries.map((e) => _TaskCard(
                                  key: ValueKey('task_m_${e.key}'),
                                  label: e.value.title,
                                  globalIndex: e.key,
                                  done: _done.contains(e.value.id),
                                  onTap: () => _toggleTask(e.value.id),
                                )),
                            const SizedBox(height: 12),
                            _SectionHeader(
                              svgAsset: 'assets/icons/moon.svg',
                              iconColor: const Color(0xFF5848B0),
                              text: 'Kechqurun',
                              doneCount: _evening
                                  .where((s) => _done.contains(s.id))
                                  .length,
                              total: _evening.length,
                            ),
                            ..._evening.asMap().entries.map((e) => _TaskCard(
                                  key: ValueKey('task_e_${e.key}'),
                                  label: e.value.title,
                                  globalIndex: _morning.length + e.key,
                                  done: _done.contains(e.value.id),
                                  onTap: () => _toggleTask(e.value.id),
                                )),
                            const SizedBox(height: 100),
                          ],
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Static background widgets ─────────────────────────────────
// Extracted so they don't participate in task-toggle rebuilds.

class _BugunBackground extends StatelessWidget {
  const _BugunBackground();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFD4CDF0),
            Color(0xFFE8E4F8),
            Color(0xFFF5F2FC),
          ],
          stops: [0.0, 0.35, 1.0],
        ),
      ),
      child: SizedBox.expand(),
    );
  }
}

class _BugunSunGlow extends StatelessWidget {
  final double screenWidth;
  const _BugunSunGlow({required this.screenWidth});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -100,
      left: screenWidth * 0.5 - 190,
      child: Container(
        width: 380,
        height: 380,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              const Color(0xFFE6D2CB),
              const Color(0xFFDBBCCC).withValues(alpha: 0.60),
              const Color(0xFFD1C6E4).withValues(alpha: 0.20),
              Colors.transparent,
            ],
            stops: const [0.0, 0.38, 0.68, 1.0],
          ),
        ),
      ),
    );
  }
}

// ── No-profile CTA ───────────────────────────────────────────

class _NoProfileCta extends StatelessWidget {
  final VoidCallback onTap;
  const _NoProfileCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 100),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Column(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B72CC), Color(0xFF5040A0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Icon(
                  Icons.face_retouching_natural_rounded,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Teri tahlilini boshlang',
                style: GoogleFonts.nunito(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF4A3C90),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Shaxsiy parvarish dasturingizni olish uchun qisqa tahlil o'ting.",
                textAlign: TextAlign.center,
                style: GoogleFonts.nunito(
                  fontSize: 13,
                  color: const Color(0xFF9490B0),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B72CC), Color(0xFF5040A0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF5040A0).withValues(alpha: 0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Tahlilni boshlash',
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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
}

// ── Streak calendar bottom sheet ──────────────────────────────

class _StreakCalendarSheet extends StatefulWidget {
  final Map<String, bool> streaks;
  final int currentStreak;
  final String Function(DateTime) dateKeyFn;

  const _StreakCalendarSheet({
    required this.streaks,
    required this.currentStreak,
    required this.dateKeyFn,
  });

  @override
  State<_StreakCalendarSheet> createState() => _StreakCalendarSheetState();
}

class _StreakCalendarSheetState extends State<_StreakCalendarSheet> {
  late DateTime _month;

  static const _dayLabels = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];
  static const _monthNames = [
    'Yanvar', 'Fevral', 'Mart', 'Aprel', 'May', 'Iyun',
    'Iyul', 'Avgust', 'Sentabr', 'Oktabr', 'Noyabr', 'Dekabr',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = DateTime(now.year, now.month, 1);
  }

  void _prevMonth() =>
      setState(() => _month = DateTime(_month.year, _month.month - 1, 1));

  void _nextMonth() {
    final now = DateTime.now();
    final next = DateTime(_month.year, _month.month + 1, 1);
    if (!next.isAfter(DateTime(now.year, now.month, 1))) {
      setState(() => _month = next);
    }
  }

  bool _isNextDisabled() {
    final now = DateTime.now();
    return _month.year == now.year && _month.month == now.month;
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).padding.bottom;
    final now = DateTime.now();
    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final firstWeekday = DateTime(_month.year, _month.month, 1).weekday;

    final cells = <Widget>[
      ...List.generate(firstWeekday - 1, (_) => const SizedBox()),
      ...List.generate(daysInMonth, (i) {
        final day = i + 1;
        final date = DateTime(_month.year, _month.month, day);
        final key = widget.dateKeyFn(date);
        final isToday = date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
        final isFuture =
            date.isAfter(DateTime(now.year, now.month, now.day));
        final isCompleted = widget.streaks[key] == true;

        return _CalendarDay(
          day: day,
          isToday: isToday,
          isCompleted: isCompleted,
          isFuture: isFuture,
        );
      }),
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFE0DCF0),
              borderRadius: BorderRadius.circular(999),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _NavButton(icon: Icons.chevron_left_rounded, onTap: _prevMonth),
              Expanded(
                child: Text(
                  '${_monthNames[_month.month - 1]} ${_month.year}',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.nunito(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF4A3C90),
                  ),
                ),
              ),
              _NavButton(
                icon: Icons.chevron_right_rounded,
                onTap: _isNextDisabled() ? null : _nextMonth,
                disabled: _isNextDisabled(),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: _dayLabels
                .map((l) => SizedBox(
                      width: 40,
                      child: Text(
                        l,
                        textAlign: TextAlign.center,
                        style: GoogleFonts.nunito(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF9490B0),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 4,
            crossAxisSpacing: 0,
            childAspectRatio: 1.0,
            children: cells,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6050B0), Color(0xFF9B7DD4)],
              ),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.local_fire_department_rounded,
                  color: Color(0xFFFFD166),
                  size: 28,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${widget.currentStreak} kun',
                      style: GoogleFonts.nunito(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Ketma-ket parvarish',
                      style: GoogleFonts.nunito(
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final bool disabled;

  const _NavButton({required this.icon, this.onTap, this.disabled = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: Color(0xFFF0ECF8),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: disabled
              ? const Color(0xFFCCC8E0)
              : const Color(0xFF6050B0),
          size: 22,
        ),
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  final int day;
  final bool isToday;
  final bool isCompleted;
  final bool isFuture;

  const _CalendarDay({
    required this.day,
    required this.isToday,
    required this.isCompleted,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              colors: [Color(0xFF6050B0), Color(0xFF9B7DD4)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Icon(Icons.check_rounded, size: 16, color: Colors.white),
          ),
        ),
      );
    }

    if (isToday) {
      return Center(
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFF6050B0), width: 2),
          ),
          child: Center(
            child: Text(
              '$day',
              style: GoogleFonts.nunito(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF4A3C90),
              ),
            ),
          ),
        ),
      );
    }

    final color = isFuture
        ? const Color(0xFFDDD9F0)
        : const Color(0xFFBBB7D5);

    return Center(
      child: SizedBox(
        width: 36,
        height: 36,
        child: Center(
          child: Text(
            '$day',
            style: GoogleFonts.nunito(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Goal badge ────────────────────────────────────────────────

class _GoalBadge extends StatelessWidget {
  final int done;
  final int total;
  const _GoalBadge({required this.done, required this.total});

  @override
  Widget build(BuildContext context) {
    final allDone = done == total && total > 0;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.85)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            allDone
                ? Icons.check_circle_rounded
                : Icons.track_changes_rounded,
            size: 14,
            color: allDone
                ? const Color(0xFF4CAF50)
                : const Color(0xFF5040A0),
          ),
          const SizedBox(width: 6),
          Text(
            allDone ? 'Hammasi bajarildi!' : 'Parvarish maqsadi',
            style: GoogleFonts.nunito(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: allDone
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF5040A0),
            ),
          ),
        ],
      ),
    ).animate(key: const ValueKey('goal_badge')).fadeIn(delay: 120.ms);
  }
}

// ── Week strip ────────────────────────────────────────────────

class _WeekStrip extends StatelessWidget {
  final DateTime today;
  final Map<String, bool> streaks;
  final Map<String, double> dailyProgress;
  final double todayProgress;
  final String Function(DateTime) dateKeyFn;

  const _WeekStrip({
    required this.today,
    required this.streaks,
    required this.dailyProgress,
    required this.todayProgress,
    required this.dateKeyFn,
  });

  static const _labels = ['Du', 'Se', 'Ch', 'Pa', 'Ju', 'Sh', 'Ya'];

  @override
  Widget build(BuildContext context) {
    final offset = today.weekday - 1;
    final monday = today.subtract(Duration(days: offset));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(7, (i) {
        final day = monday.add(Duration(days: i));
        final isToday = day.day == today.day &&
            day.month == today.month &&
            day.year == today.year;
        final isFuture = day.isAfter(today);
        final isCompleted = streaks[dateKeyFn(day)] == true;

        final double dayPct = isToday
            ? todayProgress
            : isFuture
                ? 0.0
                : dailyProgress[dateKeyFn(day)] ?? 0.0;

        final barColor = isToday
            ? Colors.white
            : dayPct >= 1.0
                ? const Color(0xFF7060AA)
                : const Color(0xFFB0A8D8);

        return Container(
          width: 44,
          height: 76,
          decoration: BoxDecoration(
            color: isToday
                ? const Color(0xFF4A3A9A)
                : Colors.white.withValues(alpha: 0.70),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Text(
                _labels[i],
                style: GoogleFonts.nunito(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isToday
                      ? Colors.white.withValues(alpha: 0.75)
                      : const Color(0xFF7060AA),
                ),
              ),
              const SizedBox(height: 5),
              Container(
                width: 28,
                height: 28,
                decoration: isToday
                    ? BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.20),
                      )
                    : null,
                child: Center(
                  child: isCompleted && !isToday
                      ? const Icon(Icons.check_rounded,
                          size: 15, color: Color(0xFF6050B0))
                      : !isToday && !isFuture && dayPct > 0 && dayPct < 1.0
                          ? Text(
                              '${(dayPct * 100).round()}%',
                              style: GoogleFonts.nunito(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF6050B0),
                              ),
                            )
                          : Text(
                              '${day.day}',
                              style: GoogleFonts.nunito(
                                fontSize: isToday ? 15 : 13,
                                fontWeight: FontWeight.w700,
                                color: isToday
                                    ? Colors.white
                                    : isFuture
                                        ? const Color(0xFFCCC8E0)
                                        : const Color(0xFF4A3C90),
                              ),
                            ),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.fromLTRB(7, 0, 7, 7),
                child: isFuture
                    ? const SizedBox(height: 3)
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(999),
                        child: LinearProgressIndicator(
                          value: dayPct,
                          backgroundColor: isToday
                              ? Colors.white.withValues(alpha: 0.20)
                              : const Color(0xFFE0DCF0),
                          valueColor: AlwaysStoppedAnimation(barColor),
                          minHeight: 3,
                        ),
                      ),
              ),
            ],
          ),
        );
      }),
    ).animate(key: const ValueKey('week_strip')).fadeIn(delay: 80.ms);
  }
}

// ── Section header ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String svgAsset;
  final Color iconColor;
  final String text;
  final int doneCount;
  final int total;

  const _SectionHeader({
    required this.svgAsset,
    required this.iconColor,
    required this.text,
    required this.doneCount,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: SvgPicture.asset(
                svgAsset,
                width: 17,
                height: 17,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            text,
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4A3C90),
              letterSpacing: 0.2,
            ),
          ),
          const Spacer(),
          Text(
            '$doneCount/$total',
            style: GoogleFonts.nunito(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: doneCount == total && total > 0
                  ? const Color(0xFF4CAF50)
                  : const Color(0xFF9490B0),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Task card ─────────────────────────────────────────────────
//
// StatefulWidget so the entrance animation controller lives in State and
// plays exactly once — it survives parent setState calls without replaying.

class _TaskCard extends StatefulWidget {
  final String label;
  final int globalIndex;
  final bool done;
  final VoidCallback? onTap;

  const _TaskCard({
    super.key,
    required this.label,
    required this.globalIndex,
    required this.done,
    required this.onTap,
  });

  @override
  State<_TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<_TaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fade;
  late final Animation<double> _slideY;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideY = Tween<double>(begin: 0.8, end: 0.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    // Stagger entrance delay per card index.
    Future.delayed(
      Duration(milliseconds: widget.globalIndex * 50),
      () {
        if (mounted) _ctrl.forward();
      },
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final done = widget.done;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, child) => Opacity(
        opacity: _fade.value.clamp(0.0, 1.0),
        child: Transform.translate(
          offset: Offset(0, _slideY.value),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            decoration: BoxDecoration(
              color: done
                  ? const Color(0xFFE8E4F5)
                  : Colors.white.withValues(alpha: 0.95),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? const Color(0xFF6050B0)
                        : Colors.transparent,
                    border: Border.all(
                      color: done
                          ? const Color(0xFF6050B0)
                          : const Color(0xFFCCC8E0),
                      width: 1.8,
                    ),
                  ),
                  child: done
                      ? const Icon(Icons.check_rounded,
                          size: 16, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    widget.label,
                    style: GoogleFonts.nunito(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: done
                          ? const Color(0xFFB8B5D0)
                          : const Color(0xFF332C60),
                      decoration: done ? TextDecoration.lineThrough : null,
                      decorationColor: const Color(0xFFB8B5D0),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
