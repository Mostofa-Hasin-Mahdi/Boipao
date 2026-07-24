import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  final url = 'https://hbwvxiwljybthkwgfvlb.supabase.co/rest/v1/claims?select=id,status,requester_id,material_id,created_at,materials!inner(id,title,donor_id,images,profiles(display_name,avatar_url)),requester:profiles!claims_requester_id_fkey(display_name,avatar_url)';
  final anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhid3Z4aXdsanlidGhrd2dmdmxiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Nzg3Njg5NTAsImV4cCI6MjA5NDM0NDk1MH0.Aa5zbYT1X6ybACjqGFoGZhwMv5W2aoprj0kYhbjfjrU';
  
  final res = await http.get(Uri.parse(url), headers: {
    'apikey': anonKey,
    'Authorization': 'Bearer $anonKey',
  });
  
  print('Status: ${res.statusCode}');
  print('Body: ${res.body}');
}
