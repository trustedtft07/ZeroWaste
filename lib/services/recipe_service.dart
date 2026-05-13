import 'dart:convert';
import 'package:http/http.dart' as http;

class RecipeService {
  // Dapatkan API key GRATIS di: https://console.groq.com/keys
  // Free tier: 30 req/menit, 14.400 req/hari - tidak perlu kartu kredit
  static const String _apiKey = 'YOUR_GROQ_API_KEY';

  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  // llama-3.1-8b-instant: cepat, hemat token, gratis
  static const String _model = 'llama-3.1-8b-instant';

  Future<String> generateRecipe(List<String> ingredients) async {
    if (ingredients.isEmpty) return 'Tidak ada bahan yang dipilih.';

    if (_apiKey == 'YOUR_GROQ_API_KEY') {
      return '⚠️ Groq API Key belum diisi.\n\n'
          'Buat key gratis di: https://console.groq.com/keys\n'
          'Lalu isi di lib/services/recipe_service.dart';
    }

    // Bahan yang dipilih jadi bahan UTAMA yang wajib dipakai semua
    final bahanUtama = ingredients.join(', ');
    final prompt =
        'Kamu asisten dapur Indonesia. '
        'Bahan UTAMA yang WAJIB digunakan semua: $bahanUtama. '
        'Buat 2 resep masakan Indonesia yang menggunakan SEMUA bahan utama tersebut sebagai campuran. '
        'Boleh tambahkan bahan pelengkap secukupnya. '
        'Format tiap resep:\n'
        '**[Nama Masakan]**\n'
        '**Bahan utama:** [sebutkan bahan yang dipilih]\n'
        '**Bahan pelengkap:** [bahan tambahan]\n'
        '**Cara memasak:**\n'
        '1. [langkah]\n'
        '2. [langkah]\n'
        '3. [langkah]\n'
        'Jawab dalam Bahasa Indonesia yang ramah.';

    try {
      final response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $_apiKey',
            },
            body: jsonEncode({
              'model': _model,
              'messages': [
                {'role': 'user', 'content': prompt}
              ],
              'max_tokens': 512,   // hemat token
              'temperature': 0.7,
            }),
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final text =
            data['choices']?[0]?['message']?['content'] as String?;
        return text?.trim() ?? 'Tidak dapat menghasilkan resep.';
      }

      return _handleError(response.statusCode, response.body);
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        return '⚠️ Request timeout. Coba lagi.';
      }
      return '⚠️ Koneksi gagal. Periksa internet.';
    }
  }

  String _handleError(int status, String body) {
    try {
      final msg = jsonDecode(body)['error']?['message'] as String? ?? '';
      if (status == 429) {
        return '⚠️ Rate limit tercapai.\nGroq free tier: 30 req/menit.\nTunggu sebentar lalu coba lagi.';
      }
      if (status == 401) {
        return '⚠️ API Key tidak valid.\nCek kembali key di https://console.groq.com/keys';
      }
      return '⚠️ Error $status: $msg';
    } catch (_) {
      return '⚠️ Error $status. Coba lagi.';
    }
  }
}
