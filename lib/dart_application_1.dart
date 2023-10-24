import 'package:http/http.dart' as http;
import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';
import 'package:postgres/postgres.dart';

Future<void> crawlAndInsert(String url, PostgreSQLConnection connection) async {
  final response = await http.get(Uri.parse(url));

  if (response.statusCode == 200) {
    final document = parse(response.body);
    final rows = document.querySelectorAll('tr'); // Select all table rows

    for (var row in rows) {
      final columns = row.querySelectorAll('td'); // Select all table data cells

      if (columns.length >= 3) {
        final populationnumb = columns[1].text.trim();
        final populationpercent = columns[2].text.trim();
        print(
            'Population Number: $populationnumb, Population Percentage: $populationpercent');

        await connection.query(
            'INSERT INTO population_data (populationnumb, populationpercent) VALUES (@populationnumb, @populationpercent)',
            substitutionValues: {
              'populationnumb': populationnumb,
              'populationpercent': populationpercent,
            });
      }
    }
  }
}

void main() async {
  final startUrl =
      'https://en.wikipedia.org/wiki/List_of_countries_and_dependencies_by_population';

  final connection = PostgreSQLConnection('localhost', 5432, 'PopulationNumb',
      username: 'postgres', password: 'asdzxc123456');
  await connection.open();

  await crawlAndInsert(startUrl, connection);

  await connection.close();
}
