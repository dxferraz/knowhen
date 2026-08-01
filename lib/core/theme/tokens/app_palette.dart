import 'package:flutter/material.dart';

/// Paleta bruta ("primitive tokens") do Knowhen.
///
/// Esta é a única camada onde valores hexadecimais literais existem.
/// Nenhuma tela deve importar este arquivo diretamente: use os tokens
/// semânticos de [AppColors] ou o `ColorScheme` do tema.
///
/// A paleta foi construída em torno da metáfora do app — tempo, céu noturno
/// e revelação — e calibrada para Glassmorphism: matizes saturados o bastante
/// para "vazarem" através do vidro, com rampas neutras levemente violeta
/// para que sombras e bordas nunca pareçam sujas/acinzentadas.
abstract final class AppPalette {
  // ---------------------------------------------------------------------
  // Neutros (Ink) — base violeta-fria. Usada para texto, bordas e fundos.
  // ---------------------------------------------------------------------
  static const ink50 = Color(0xFFF6F6FB);
  static const ink100 = Color(0xFFEDEDF6);
  static const ink200 = Color(0xFFDCDBEB);
  static const ink300 = Color(0xFFC2C0DC);
  static const ink400 = Color(0xFF9E9BC2);
  static const ink500 = Color(0xFF7B77A3);
  static const ink600 = Color(0xFF5C5883);
  static const ink700 = Color(0xFF423F63);
  static const ink800 = Color(0xFF2A2846);
  static const ink900 = Color(0xFF191734);
  static const ink950 = Color(0xFF0E0C22);

  // ---------------------------------------------------------------------
  // Iris (primária) — violeta/índigo. A cor da marca e das ações principais.
  // ---------------------------------------------------------------------
  static const iris50 = Color(0xFFF1EEFF);
  static const iris100 = Color(0xFFE4DEFF);
  static const iris200 = Color(0xFFCBBFFF);
  static const iris300 = Color(0xFFAC99FF);
  static const iris400 = Color(0xFF8E73FF);
  static const iris500 = Color(0xFF6D4AFF);
  static const iris600 = Color(0xFF5A32F0);
  static const iris700 = Color(0xFF4A25CC);
  static const iris800 = Color(0xFF3A1E9E);
  static const iris900 = Color(0xFF2A1673);

  // ---------------------------------------------------------------------
  // Aqua (secundária) — ciano/turquesa. Dados, tempo, precisão.
  // ---------------------------------------------------------------------
  static const aqua50 = Color(0xFFE6FBFB);
  static const aqua100 = Color(0xFFC6F6F7);
  static const aqua200 = Color(0xFF93EDF0);
  static const aqua300 = Color(0xFF5CDFE6);
  static const aqua400 = Color(0xFF2CC9D4);
  static const aqua500 = Color(0xFF12ABB8);
  static const aqua600 = Color(0xFF0C8A97);
  static const aqua700 = Color(0xFF0B6D79);
  static const aqua800 = Color(0xFF0C555E);
  static const aqua900 = Color(0xFF0A444B);

  // ---------------------------------------------------------------------
  // Solar (terciária) — âmbar/dourado. Destaques, marca ("w" do logo), sol.
  // ---------------------------------------------------------------------
  static const solar50 = Color(0xFFFFF7E8);
  static const solar100 = Color(0xFFFFEDCB);
  static const solar200 = Color(0xFFFFD991);
  static const solar300 = Color(0xFFFFC15C);
  static const solar400 = Color(0xFFFFA831);
  static const solar500 = Color(0xFFF08A0E);
  static const solar600 = Color(0xFFC86A08);
  static const solar700 = Color(0xFFA0510B);
  static const solar800 = Color(0xFF7C3F0F);
  static const solar900 = Color(0xFF5E320F);

  // ---------------------------------------------------------------------
  // Nebula (acento) — rosa/magenta. Momentos emocionais (concepção, aurora).
  // ---------------------------------------------------------------------
  static const nebula50 = Color(0xFFFFEFF9);
  static const nebula100 = Color(0xFFFFDCF2);
  static const nebula200 = Color(0xFFFFB8E4);
  static const nebula300 = Color(0xFFFF8AD3);
  static const nebula400 = Color(0xFFFF5CC0);
  static const nebula500 = Color(0xFFEE33A6);
  static const nebula600 = Color(0xFFC81F87);
  static const nebula700 = Color(0xFFA0176C);
  static const nebula800 = Color(0xFF7C1554);
  static const nebula900 = Color(0xFF5E1240);

  // ---------------------------------------------------------------------
  // Feedback
  // ---------------------------------------------------------------------
  static const success300 = Color(0xFF45DDA0);
  static const success500 = Color(0xFF14B87A);
  static const success700 = Color(0xFF0A7A50);

  static const danger300 = Color(0xFFFF9EA2);
  static const danger400 = Color(0xFFFF7A80);
  static const danger500 = Color(0xFFE5484D);
  static const danger700 = Color(0xFF9E1F23);

  // ---------------------------------------------------------------------
  // Fundos absolutos (usados nos gradientes de cena)
  // ---------------------------------------------------------------------
  static const night = Color(0xFF0B0A1F);
  static const nightAlt = Color(0xFF12102B);
  static const nightDeep = Color(0xFF0D1230);
  static const dawn = Color(0xFFFBFAFF);
  static const dawnAlt = Color(0xFFF1EFFF);
  static const dawnDeep = Color(0xFFEAF4FF);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF05040F);
}
