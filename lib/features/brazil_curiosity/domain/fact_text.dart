/// Maior primeira frase que ainda cabe como título do cartão do fato.
const int maxFactTitleLength = 60;

/// Separa o fato do mês em título curto e corpo. O título ("Nasce o Mercosul") vem do Firestore quando houver um
/// campo para ele; até lá a primeira frase serve se for curta. Senão o fato inteiro é o corpo e não há título, em vez
/// de um título de cinco linhas.
({String? title, String body}) splitFact(String curiosity) {
  final sentences = curiosity.split('. ');
  final lead = sentences.first.trim().replaceFirst(RegExp(r'\.$'), '');
  if (lead.length > maxFactTitleLength) return (title: null, body: curiosity.trim());
  return (title: lead, body: sentences.skip(1).join('. ').trim());
}
