class Itinerary {
  final List<Candidate> candidates;
  final UsageMetadata? usageMetadata;
  final String? modelVersion;

  Itinerary({
    required this.candidates,
    this.usageMetadata,
    this.modelVersion,
  });

  factory Itinerary.fromJson(Map<String, dynamic> json) {
    return Itinerary(
      candidates: (json['candidates'] as List)
          .map((candidate) => Candidate.fromJson(candidate))
          .toList(),
      usageMetadata: json['usageMetadata'] != null
          ? UsageMetadata.fromJson(json['usageMetadata'])
          : null,
      modelVersion: json['modelVersion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'candidates': candidates.map((candidate) => candidate.toJson()).toList(),
      'usageMetadata': usageMetadata?.toJson(),
      'modelVersion': modelVersion,
    };
  }
}

class Candidate {
  final Content content;
  final String? finishReason;
  final double? avgLogprobs;

  Candidate({
    required this.content,
    this.finishReason,
    this.avgLogprobs,
  });

  factory Candidate.fromJson(Map<String, dynamic> json) {
    return Candidate(
      content: Content.fromJson(json['content']),
      finishReason: json['finishReason'],
      avgLogprobs: json['avgLogprobs']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content.toJson(),
      'finishReason': finishReason,
      'avgLogprobs': avgLogprobs,
    };
  }
}

class Content {
  final List<Part> parts;
  final String? role;

  Content({
    required this.parts,
    this.role,
  });

  factory Content.fromJson(Map<String, dynamic> json) {
    return Content(
      parts: (json['parts'] as List).map((part) => Part.fromJson(part)).toList(),
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parts': parts.map((part) => part.toJson()).toList(),
      'role': role,
    };
  }
}

class Part {
  final String text;

  Part({
    required this.text,
  });

  factory Part.fromJson(Map<String, dynamic> json) {
    return Part(
      text: json['text'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
    };
  }
}

class UsageMetadata {
  final int? promptTokenCount;
  final int? candidatesTokenCount;
  final int? totalTokenCount;
  final List<TokensDetail>? promptTokensDetails;
  final List<TokensDetail>? candidatesTokensDetails;

  UsageMetadata({
    this.promptTokenCount,
    this.candidatesTokenCount,
    this.totalTokenCount,
    this.promptTokensDetails,
    this.candidatesTokensDetails,
  });

  factory UsageMetadata.fromJson(Map<String, dynamic> json) {
    return UsageMetadata(
      promptTokenCount: json['promptTokenCount'],
      candidatesTokenCount: json['candidatesTokenCount'],
      totalTokenCount: json['totalTokenCount'],
      promptTokensDetails: json['promptTokensDetails'] != null
          ? (json['promptTokensDetails'] as List)
          .map((detail) => TokensDetail.fromJson(detail))
          .toList()
          : null,
      candidatesTokensDetails: json['candidatesTokensDetails'] != null
          ? (json['candidatesTokensDetails'] as List)
          .map((detail) => TokensDetail.fromJson(detail))
          .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'promptTokenCount': promptTokenCount,
      'candidatesTokenCount': candidatesTokenCount,
      'totalTokenCount': totalTokenCount,
      'promptTokensDetails':
      promptTokensDetails?.map((detail) => detail.toJson()).toList(),
      'candidatesTokensDetails':
      candidatesTokensDetails?.map((detail) => detail.toJson()).toList(),
    };
  }
}

class TokensDetail {
  final String? modality;
  final int? tokenCount;

  TokensDetail({
    this.modality,
    this.tokenCount,
  });

  factory TokensDetail.fromJson(Map<String, dynamic> json) {
    return TokensDetail(
      modality: json['modality'],
      tokenCount: json['tokenCount'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'modality': modality,
      'tokenCount': tokenCount,
    };
  }
}