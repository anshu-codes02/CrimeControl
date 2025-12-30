import 'package:flutter/material.dart';

enum BadgeType {
  // Basic Achievement Badges
  rookie,
  detective,
  expert,
  legend,
  
  // Collaboration Badges
  collaborator,
  teamPlayer,
  communicator,
  mentor,
  leader,
  
  // Speed & Efficiency Badges
  quickSolver,
  speedDemon,
  fastTrack,
  lightningBolt,
  
  // Quality & Thoroughness Badges
  thoroughInvestigator,
  perfectionist,
  detailOriented,
  analyst,
  forensicExpert,
  
  // Community & Help Badges
  communityHelper,
  goodSamaritan,
  volunteer,
  supportive,
  helpful,
  
  // Case Count Milestones
  firstCase,
  fiveCases,
  tenCases,
  twentyFiveCases,
  fiftyCases,
  hundredCases,
  twoHundredCases,
  fiveHundredCases,
  
  // Rating & Recognition Badges
  highRated,
  topRated,
  fiveStarExpert,
  crowdFavorite,
  trustedExpert,
  
  // Specialization Badges
  specialist,
  cybercrime,
  forensics,
  investigation,
  surveillance,
  criminalPsychology,
  legalExpert,
  dataAnalyst,
  
  // Time-based Badges
  earlyBird,
  nightOwl,
  weekendWarrior,
  consistent,
  dedicated,
  
  // Innovation & Creativity Badges
  innovative,
  creative,
  problemSolver,
  outOfTheBox,
  gameChanger,
  
  // Special Achievement Badges
  breakthrough,
  coldCaseSolver,
  serialCaseSolver,
  complexCaseMaster,
  evidenceFinder,
  witnessInterviewer,
  
  // Platform & System Badges
  earlyAdopter,
  betaTester,
  feedbackProvider,
  bugHunter,
  platformContributor,
  
  // Learning & Development Badges
  student,
  researcher,
  knowledgeSeeker,
  skillBuilder,
  continuous_learner,
  
  // Special Recognition Badges
  outstanding,
  exceptional,
  remarkable,
  distinguished,
  elite,
  champion,
}

class Badge {
  final int id;
  final BadgeType type;
  final String name;
  final String description;
  final IconData icon;
  final Color color;
  final String? earnedAt;
  final bool isUnlocked;

  Badge({
    required this.id,
    required this.type,
    required this.name,
    required this.description,
    required this.icon,
    required this.color,
    this.earnedAt,
    this.isUnlocked = false,
  });

  factory Badge.fromJson(Map<String, dynamic> json) {
    return Badge(
      id: json['id'] ?? 0,
      type: BadgeType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => BadgeType.rookie,
      ),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      icon: _getIconForBadgeType(json['type']),
      color: _getColorForBadgeType(json['type']),
      earnedAt: json['earnedAt'],
      isUnlocked: json['isUnlocked'] ?? false,
    );
  }

  static IconData _getIconForBadgeType(String? type) {
    switch (type) {
      // Basic Achievement Badges
      case 'rookie':
        return Icons.school;
      case 'detective':
        return Icons.search;
      case 'expert':
        return Icons.star;
      case 'legend':
        return Icons.military_tech;
      
      // Collaboration Badges
      case 'collaborator':
        return Icons.group;
      case 'teamPlayer':
        return Icons.groups;
      case 'communicator':
        return Icons.chat;
      case 'mentor':
        return Icons.supervisor_account;
      case 'leader':
        return Icons.person;
      
      // Speed & Efficiency Badges
      case 'quickSolver':
        return Icons.flash_on;
      case 'speedDemon':
        return Icons.speed;
      case 'fastTrack':
        return Icons.fast_forward;
      case 'lightningBolt':
        return Icons.electric_bolt;
      
      // Quality & Thoroughness Badges
      case 'thoroughInvestigator':
        return Icons.psychology;
      case 'perfectionist':
        return Icons.verified;
      case 'detailOriented':
        return Icons.zoom_in;
      case 'analyst':
        return Icons.analytics;
      case 'forensicExpert':
        return Icons.science;
      
      // Community & Help Badges
      case 'communityHelper':
        return Icons.volunteer_activism;
      case 'goodSamaritan':
        return Icons.favorite;
      case 'volunteer':
        return Icons.handshake;
      case 'supportive':
        return Icons.support;
      case 'helpful':
        return Icons.help_outline;
      
      // Case Count Milestones
      case 'firstCase':
        return Icons.flag;
      case 'fiveCases':
        return Icons.looks_5;
      case 'tenCases':
        return Icons.local_fire_department;
      case 'twentyFiveCases':
        return Icons.trending_up;
      case 'fiftyCases':
        return Icons.whatshot;
      case 'hundredCases':
        return Icons.emoji_events;
      case 'twoHundredCases':
        return Icons.celebration;
      case 'fiveHundredCases':
        return Icons.diamond;
      
      // Rating & Recognition Badges
      case 'highRated':
        return Icons.thumb_up;
      case 'topRated':
        return Icons.star_rate;
      case 'fiveStarExpert':
        return Icons.stars;
      case 'crowdFavorite':
        return Icons.people;
      case 'trustedExpert':
        return Icons.verified_user;
      
      // Specialization Badges
      case 'specialist':
        return Icons.workspace_premium;
      case 'cybercrime':
        return Icons.computer;
      case 'forensics':
        return Icons.biotech;
      case 'investigation':
        return Icons.manage_search;
      case 'surveillance':
        return Icons.videocam;
      case 'criminalPsychology':
        return Icons.psychology_alt;
      case 'legalExpert':
        return Icons.gavel;
      case 'dataAnalyst':
        return Icons.bar_chart;
      
      // Time-based Badges
      case 'earlyBird':
        return Icons.wb_sunny;
      case 'nightOwl':
        return Icons.nights_stay;
      case 'weekendWarrior':
        return Icons.weekend;
      case 'consistent':
        return Icons.trending_flat;
      case 'dedicated':
        return Icons.loyalty;
      
      // Innovation & Creativity Badges
      case 'innovative':
        return Icons.lightbulb;
      case 'creative':
        return Icons.palette;
      case 'problemSolver':
        return Icons.build;
      case 'outOfTheBox':
        return Icons.auto_awesome;
      case 'gameChanger':
        return Icons.transform;
      
      // Special Achievement Badges
      case 'breakthrough':
        return Icons.rocket_launch;
      case 'coldCaseSolver':
        return Icons.ac_unit;
      case 'serialCaseSolver':
        return Icons.link;
      case 'complexCaseMaster':
        return Icons.extension;
      case 'evidenceFinder':
        return Icons.search_off;
      case 'witnessInterviewer':
        return Icons.record_voice_over;
      
      // Platform & System Badges
      case 'earlyAdopter':
        return Icons.new_releases;
      case 'betaTester':
        return Icons.bug_report;
      case 'feedbackProvider':
        return Icons.feedback;
      case 'bugHunter':
        return Icons.pest_control;
      case 'platformContributor':
        return Icons.code;
      
      // Learning & Development Badges
      case 'student':
        return Icons.school_outlined;
      case 'researcher':
        return Icons.find_in_page;
      case 'knowledgeSeeker':
        return Icons.menu_book;
      case 'skillBuilder':
        return Icons.construction;
      case 'continuous_learner':
        return Icons.auto_stories;
      
      // Special Recognition Badges
      case 'outstanding':
        return Icons.workspace_premium;
      case 'exceptional':
        return Icons.star;
      case 'remarkable':
        return Icons.recommend;
      case 'distinguished':
        return Icons.military_tech;
      case 'elite':
        return Icons.diamond;
      case 'champion':
        return Icons.emoji_events;
      
      default:
        return Icons.badge;
    }
  }

  static Color _getColorForBadgeType(String? type) {
    switch (type) {
      // Basic Achievement Badges
      case 'rookie':
        return Colors.green;
      case 'detective':
        return Colors.blue;
      case 'expert':
        return Colors.purple;
      case 'legend':
        return Colors.amber;
      
      // Collaboration Badges
      case 'collaborator':
        return Colors.orange;
      case 'teamPlayer':
        return Colors.blueAccent;
      case 'communicator':
        return Colors.lightBlue;
      case 'mentor':
        return Colors.teal;
      case 'leader':
        return Colors.indigo;
      
      // Speed & Efficiency Badges
      case 'quickSolver':
        return Colors.yellow;
      case 'speedDemon':
        return Colors.red;
      case 'fastTrack':
        return Colors.orange;
      case 'lightningBolt':
        return Colors.yellowAccent;
      
      // Quality & Thoroughness Badges
      case 'thoroughInvestigator':
        return Colors.indigo;
      case 'perfectionist':
        return Colors.deepPurple;
      case 'detailOriented':
        return Colors.purple;
      case 'analyst':
        return Colors.blueGrey;
      case 'forensicExpert':
        return Colors.teal;
      
      // Community & Help Badges
      case 'communityHelper':
        return Colors.pink;
      case 'goodSamaritan':
        return Colors.pinkAccent;
      case 'volunteer':
        return Colors.green;
      case 'supportive':
        return Colors.lightGreen;
      case 'helpful':
        return Colors.greenAccent;
      
      // Case Count Milestones
      case 'firstCase':
        return Colors.lightGreen;
      case 'fiveCases':
        return Colors.green;
      case 'tenCases':
        return Colors.red;
      case 'twentyFiveCases':
        return Colors.orange;
      case 'fiftyCases':
        return Colors.deepOrange;
      case 'hundredCases':
        return Colors.deepOrange;
      case 'twoHundredCases':
        return Colors.purple;
      case 'fiveHundredCases':
        return Colors.deepPurple;
      
      // Rating & Recognition Badges
      case 'highRated':
        return Colors.cyan;
      case 'topRated':
        return Colors.blue;
      case 'fiveStarExpert':
        return Colors.amber;
      case 'crowdFavorite':
        return Colors.pink;
      case 'trustedExpert':
        return Colors.indigo;
      
      // Specialization Badges
      case 'specialist':
        return Colors.deepPurple;
      case 'cybercrime':
        return Colors.blueGrey;
      case 'forensics':
        return Colors.teal;
      case 'investigation':
        return Colors.brown;
      case 'surveillance':
        return Colors.grey;
      case 'criminalPsychology':
        return Colors.deepPurple;
      case 'legalExpert':
        return Colors.brown;
      case 'dataAnalyst':
        return Colors.blue;
      
      // Time-based Badges
      case 'earlyBird':
        return Colors.yellow;
      case 'nightOwl':
        return Colors.indigo;
      case 'weekendWarrior':
        return Colors.orange;
      case 'consistent':
        return Colors.green;
      case 'dedicated':
        return Colors.red;
      
      // Innovation & Creativity Badges
      case 'innovative':
        return Colors.lightBlue;
      case 'creative':
        return Colors.purple;
      case 'problemSolver':
        return Colors.teal;
      case 'outOfTheBox':
        return Colors.pink;
      case 'gameChanger':
        return Colors.deepOrange;
      
      // Special Achievement Badges
      case 'breakthrough':
        return Colors.amber;
      case 'coldCaseSolver':
        return Colors.lightBlue;
      case 'serialCaseSolver':
        return Colors.red;
      case 'complexCaseMaster':
        return Colors.deepPurple;
      case 'evidenceFinder':
        return Colors.brown;
      case 'witnessInterviewer':
        return Colors.green;
      
      // Platform & System Badges
      case 'earlyAdopter':
        return Colors.cyan;
      case 'betaTester':
        return Colors.orange;
      case 'feedbackProvider':
        return Colors.blue;
      case 'bugHunter':
        return Colors.red;
      case 'platformContributor':
        return Colors.purple;
      
      // Learning & Development Badges
      case 'student':
        return Colors.lightGreen;
      case 'researcher':
        return Colors.blueGrey;
      case 'knowledgeSeeker':
        return Colors.brown;
      case 'skillBuilder':
        return Colors.orange;
      case 'continuous_learner':
        return Colors.teal;
      
      // Special Recognition Badges
      case 'outstanding':
        return Colors.amber;
      case 'exceptional':
        return Colors.deepOrange;
      case 'remarkable':
        return Colors.purple;
      case 'distinguished':
        return Colors.indigo;
      case 'elite':
        return Colors.deepPurple;
      case 'champion':
        return Colors.amber;
      
      default:
        return Colors.grey;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.toString().split('.').last,
      'name': name,
      'description': description,
      'earnedAt': earnedAt,
      'isUnlocked': isUnlocked,
    };
  }
}

// Predefined badges with their criteria
class BadgeDefinitions {
  static List<Badge> getAllBadges() {
    return [
      Badge(
        id: 1,
        type: BadgeType.rookie,
        name: 'Rookie Investigator',
        description: 'Welcome to CrimeNet! Complete your first case.',
        icon: Icons.school,
        color: Colors.green,
      ),
      Badge(
        id: 2,
        type: BadgeType.detective,
        name: 'Detective',
        description: 'Solve 5 cases successfully.',
        icon: Icons.search,
        color: Colors.blue,
      ),
      Badge(
        id: 3,
        type: BadgeType.expert,
        name: 'Expert Investigator',
        description: 'Solve 25 cases with high ratings.',
        icon: Icons.star,
        color: Colors.purple,
      ),
      Badge(
        id: 4,
        type: BadgeType.legend,
        name: 'Legend',
        description: 'Solve 100 cases and maintain 4.5+ average rating.',
        icon: Icons.military_tech,
        color: Colors.amber,
      ),
      Badge(
        id: 5,
        type: BadgeType.collaborator,
        name: 'Team Player',
        description: 'Participate in 10 collaborative cases.',
        icon: Icons.group,
        color: Colors.orange,
      ),
      Badge(
        id: 6,
        type: BadgeType.quickSolver,
        name: 'Quick Solver',
        description: 'Solve 5 cases within 24 hours of posting.',
        icon: Icons.flash_on,
        color: Colors.yellow,
      ),
      Badge(
        id: 7,
        type: BadgeType.thoroughInvestigator,
        name: 'Thorough Investigator',
        description: 'Provide detailed analysis in 20 cases.',
        icon: Icons.psychology,
        color: Colors.indigo,
      ),
      Badge(
        id: 8,
        type: BadgeType.communityHelper,
        name: 'Community Helper',
        description: 'Help 50 different investigators.',
        icon: Icons.volunteer_activism,
        color: Colors.pink,
      ),
      Badge(
        id: 9,
        type: BadgeType.firstCase,
        name: 'First Case',
        description: 'Complete your very first case.',
        icon: Icons.flag,
        color: Colors.lightGreen,
      ),
      Badge(
        id: 10,
        type: BadgeType.tenCases,
        name: 'Case Crusher',
        description: 'Solve 10 cases.',
        icon: Icons.local_fire_department,
        color: Colors.red,
      ),
      Badge(
        id: 11,
        type: BadgeType.hundredCases,
        name: 'Century Solver',
        description: 'Solve 100 cases.',
        icon: Icons.emoji_events,
        color: Colors.deepOrange,
      ),
      Badge(
        id: 12,
        type: BadgeType.highRated,
        name: 'Highly Rated',
        description: 'Maintain 4.0+ average rating with 10+ ratings.',
        icon: Icons.thumb_up,
        color: Colors.cyan,
      ),
      Badge(
        id: 13,
        type: BadgeType.mentor,
        name: 'Mentor',
        description: 'Guide and help 10 rookie investigators.',
        icon: Icons.supervisor_account,
        color: Colors.teal,
      ),
      Badge(
        id: 14,
        type: BadgeType.specialist,
        name: 'Specialist',
        description: 'Excel in a specific crime category (20+ cases).',
        icon: Icons.workspace_premium,
        color: Colors.deepPurple,
      ),
    ];
  }
}
