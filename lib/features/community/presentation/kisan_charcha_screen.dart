import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/agri_card.dart';
import '../../../core/widgets/custom_button.dart';

class CommunityPost {
  final String id;
  final String authorName;
  final String authorRole;
  final String location;
  final String cropName;
  final String title;
  final String content;
  int upvotes;
  bool isUpvoted;
  final bool aiVerified;
  final bool expertVerified;
  final String timeAgo;
  final List<CommunityReply> replies;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.location,
    required this.cropName,
    required this.title,
    required this.content,
    required this.upvotes,
    this.isUpvoted = false,
    required this.aiVerified,
    required this.expertVerified,
    required this.timeAgo,
    required this.replies,
  });
}

class CommunityReply {
  final String id;
  final String authorName;
  final String authorRole;
  final String content;
  final bool isAgronomist;
  final String timeAgo;

  CommunityReply({
    required this.id,
    required this.authorName,
    required this.authorRole,
    required this.content,
    required this.isAgronomist,
    required this.timeAgo,
  });
}

class KisanCharchaScreen extends StatefulWidget {
  const KisanCharchaScreen({super.key});

  @override
  State<KisanCharchaScreen> createState() => _KisanCharchaScreenState();
}

class _KisanCharchaScreenState extends State<KisanCharchaScreen> {
  String _selectedCropFilter = 'All';
  final List<String> _cropFilters = ['All', 'Cotton', 'Chilli', 'Tomato', 'Paddy'];

  late List<CommunityPost> _posts;

  @override
  void initState() {
    super.initState();
    _posts = [
      CommunityPost(
        id: 'POST-101',
        authorName: 'Ramesh Patel',
        authorRole: 'Cotton Grower (3.5 Acres)',
        location: 'Warangal, Telangana',
        cropName: 'Cotton',
        title: 'Pink Bollworm entry holes noticed on 45-day Bt cotton - best knapsack spray?',
        content: 'Noticed rosette flowers and entrance boreholes on green bolls yesterday. Temperature is 31°C with 70% humidity. Should I spray Profenofos or Emamectin Benzoate? Please suggest exact tank dilution.',
        upvotes: 35,
        aiVerified: true,
        expertVerified: true,
        timeAgo: '2 hours ago',
        replies: [
          CommunityReply(
            id: 'REP-1',
            authorName: 'Dr. V. K. Rao (ICAR Agronomist)',
            authorRole: 'Senior Crop Protection Specialist',
            content: 'Spray Emamectin Benzoate 5% SG @ 6.5g per 16L knapsack sprayer tank in late afternoon. Avoid synthetic pyrethroids as they trigger secondary whitefly outbreak.',
            isAgronomist: true,
            timeAgo: '1 hour ago',
          ),
          CommunityReply(
            id: 'REP-2',
            authorName: 'AGRI AI Advisory Bot',
            authorRole: 'AI IPM Verified Engine',
            content: 'Set up 8 pheromone traps per acre to monitor moth catch threshold (>8 moths/trap for 3 consecutive nights indicates economic threshold trigger).',
            isAgronomist: true,
            timeAgo: '45 mins ago',
          ),
        ],
      ),
      CommunityPost(
        id: 'POST-102',
        authorName: 'Srinivasulu Naidu',
        authorRole: 'Spices Cultivator',
        location: 'Guntur, AP',
        cropName: 'Chilli',
        title: 'Severe Thrips (Thrips parvispinus) leaf curling & flower drop remedy',
        content: 'Upward cup curling on upper canopy leaves with flower bud drop. Blue sticky traps caught hundreds. Looking for IPM rotation to avoid chemical resistance.',
        upvotes: 49,
        aiVerified: true,
        expertVerified: true,
        timeAgo: '4 hours ago',
        replies: [
          CommunityReply(
            id: 'REP-3',
            authorName: 'Dr. Ananya Reddy',
            authorRole: 'Horticulture Agronomist',
            content: 'IPM protocol: Spray Neem Oil 10,000 ppm @ 50ml per 16L tank. Follow up after 5 days with Spinetoram 11.7% SC @ 15ml per tank. Ensure under-leaf coverage.',
            isAgronomist: true,
            timeAgo: '3 hours ago',
          ),
        ],
      ),
      CommunityPost(
        id: 'POST-103',
        authorName: 'Gurpreet Singh',
        authorRole: 'Organic Farmer',
        location: 'Karnal, Haryana',
        cropName: 'Paddy',
        title: 'High canopy humidity detected - precautionary spray for Sheath Blight',
        content: 'Sentinel-2 radar indicated 82% micro-climate canopy humidity. Should I spray Pseudomonas fluorescens now before symptoms appear on lower leaf sheaths?',
        upvotes: 24,
        aiVerified: true,
        expertVerified: false,
        timeAgo: '6 hours ago',
        replies: [
          CommunityReply(
            id: 'REP-4',
            authorName: 'Balwinder Dhillon',
            authorRole: 'Farmer Peer',
            content: 'Yes brother, prophylactic spray of Pseudomonas @ 10g/L water gives 90% protection before fungal mycelium enters sheath tissue.',
            isAgronomist: false,
            timeAgo: '5 hours ago',
          ),
        ],
      ),
    ];
  }

  void _openAskQuestionDialog() {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    String chosenCrop = 'Cotton';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Ask Kisan Charcha', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
                ],
              ),
              const SizedBox(height: 8),
              const Text('Select Crop', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: chosenCrop,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
                items: ['Cotton', 'Chilli', 'Tomato', 'Paddy', 'Wheat', 'Maize'].map((c) {
                  return DropdownMenuItem(value: c, child: Text(c));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setModalState(() => chosenCrop = val);
                },
              ),
              const SizedBox(height: 12),
              const Text('Question Headline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  hintText: 'e.g. Yellow leaf curl on 30-day tomato crop',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 12),
              const Text('Details & Field Conditions', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              const SizedBox(height: 6),
              TextField(
                controller: contentController,
                maxLines: 3,
                decoration: InputDecoration(
                  hintText: 'Describe symptoms, soil moisture, previous sprays...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Post to Kisan Charcha',
                icon: Icons.send_rounded,
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  setState(() {
                    _posts.insert(
                      0,
                      CommunityPost(
                        id: 'POST-${DateTime.now().millisecondsSinceEpoch}',
                        authorName: 'Ramesh Kumar (You)',
                        authorRole: 'Verified Farmer',
                        location: 'Warangal, Telangana',
                        cropName: chosenCrop,
                        title: titleController.text.trim(),
                        content: contentController.text.trim().isEmpty
                            ? 'Looking for advice from certified agronomists and peer farmers.'
                            : contentController.text.trim(),
                        upvotes: 1,
                        aiVerified: true,
                        expertVerified: false,
                        timeAgo: 'Just now',
                        replies: [],
                      ),
                    );
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.primaryDark,
                      content: Text('Question published! Agronomists & AI bot notified.'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addReply(CommunityPost post) {
    final replyController = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Share Solution / Remedy', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
            const SizedBox(height: 8),
            Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary)),
            const SizedBox(height: 12),
            TextField(
              controller: replyController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Share your experience, spray recommendation, or tank dosage...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Submit Reply',
              icon: Icons.check_circle_rounded,
              onPressed: () {
                if (replyController.text.trim().isEmpty) return;
                setState(() {
                  post.replies.add(
                    CommunityReply(
                      id: 'REP-${DateTime.now().millisecondsSinceEpoch}',
                      authorName: 'Ramesh Kumar',
                      authorRole: 'Farmer Contributor',
                      content: replyController.text.trim(),
                      isAgronomist: false,
                      timeAgo: 'Just now',
                    ),
                  );
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Your advice has been shared with fellow farmers!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredPosts = _selectedCropFilter == 'All'
        ? _posts
        : _posts.where((p) => p.cropName.toLowerCase() == _selectedCropFilter.toLowerCase()).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('🌾 Kisan Charcha Forum', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Peer Farmer Discussions & ICAR Verified Agronomists', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search_rounded),
            onPressed: () {},
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.add_comment_rounded, color: Colors.white),
        label: const Text('Ask Question', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: _openAskQuestionDialog,
      ),
      body: Column(
        children: [
          // Crop Filter Chips
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.white,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _cropFilters.map((crop) {
                  final isSelected = (_selectedCropFilter == crop);
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(crop),
                      selected: isSelected,
                      selectedColor: AppColors.primaryGreen,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      onSelected: (val) {
                        if (val) setState(() => _selectedCropFilter = crop);
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),

          // Community Feed
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredPosts.length,
              itemBuilder: (context, index) {
                final post = filteredPosts[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: AgriCard(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                      // Author Row
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColors.greenSurface,
                            child: Text(
                              post.authorName[0],
                              style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 6,
                                  children: [
                                    Text(post.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                      decoration: BoxDecoration(
                                        color: AppColors.greenSurface,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        post.cropName,
                                        style: const TextStyle(color: AppColors.primaryDark, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${post.location} • ${post.timeAgo}',
                                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title & Content
                      Text(
                        post.title,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.textPrimary),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        post.content,
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary, height: 1.4),
                      ),
                      const SizedBox(height: 12),

                      // Badges Row
                      Wrap(
                        spacing: 8,
                        children: [
                          if (post.aiVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.greenSurface,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.auto_awesome, color: AppColors.primaryGreen, size: 12),
                                  SizedBox(width: 4),
                                  Text('AI Agronomist Verified', style: TextStyle(color: AppColors.primaryDark, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          if (post.expertVerified)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE3F2FD),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified, color: Colors.blue, size: 12),
                                  SizedBox(width: 4),
                                  Text('ICAR Scientist Certified', style: TextStyle(color: Colors.blue, fontSize: 10, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 24),

                      // Actions: Upvote & Reply
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                if (post.isUpvoted) {
                                  post.upvotes--;
                                  post.isUpvoted = false;
                                } else {
                                  post.upvotes++;
                                  post.isUpvoted = true;
                                }
                              });
                            },
                            borderRadius: BorderRadius.circular(8),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Icon(
                                    post.isUpvoted ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                                    size: 16,
                                    color: post.isUpvoted ? AppColors.primaryGreen : AppColors.textSecondary,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    '${post.upvotes} Helpful',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: post.isUpvoted ? AppColors.primaryGreen : AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () => _addReply(post),
                            borderRadius: BorderRadius.circular(8),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              child: Row(
                                children: [
                                  Icon(Icons.reply_rounded, size: 16, color: AppColors.primaryGreen),
                                  SizedBox(width: 6),
                                  Text(
                                    'Reply Remedy',
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Expert & Peer Replies Section
                      if (post.replies.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'SOLUTIONS & AGRO-ADVICE (${post.replies.length})',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary, letterSpacing: 0.8),
                              ),
                              const SizedBox(height: 8),
                              ...post.replies.map((reply) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Wrap(
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      spacing: 6,
                                      children: [
                                        Text(reply.authorName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        if (reply.isAgronomist)
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryGreen,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: const Text('Agronomist', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(reply.content, style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.35)),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
            ),
          ),
        ],
      ),
    );
  }
}
