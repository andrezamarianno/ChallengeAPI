import Foundation

// Estrutura para armazenar os dados do CSV
struct CSVRow {
    let id: Int
    let equipamento: String
    let nome: String
    let cep: String
    let latitude: Double
    let longitude: Double
    let logradouro: String
    let tipoLocalidade: String
    let bairro: String
    let subprefeitura: String
    let regiao: String
    let pontosDeAcesso: String
}

// Array global para armazenar os dados do CSV
var csvData: [CSVRow] = []

func fetchAndProcessCSV() {
    let urlString = "http://dados.prefeitura.sp.gov.br/dataset/37ff064f-2626-4fbc-8bbf-aee16cf4716e/resource/09dbc69e-f49f-4a2c-b15d-25186d07a74f/download/pontos_wifi___geosampa__2_.csv"
    
    guard let encodedURLString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
          let url = URL(string: encodedURLString) else {
        print("URL inválida.")
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    
    let task = URLSession.shared.dataTask(with: request) { data, response, error in
        if let error = error {
            print("Erro ao fazer a requisição: \(error)")
            return
        }
        
        guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
            print("Resposta inválida do servidor.")
            return
        }
        
        guard let data = data else {
            print("Dados não recebidos.")
            return
        }
        
        if let csvString = String(data: data, encoding: .utf8) {
            processCSV(csvString)
        } else if let csvString = String(data: data, encoding: .isoLatin1) {
            processCSV(csvString)
        } else {
            print("Erro ao converter dados para string")
        }
        
        // Imprimir dados após o processamento
        printCSVData()
    }
    
    task.resume()
    
    // Aguardar a tarefa ser concluída (aguarda 10 segundos antes de encerrar o programa)
    RunLoop.main.run(until: Date().addingTimeInterval(10))
}

func processCSV(_ csvString: String) {
    let csvLines = csvString.components(separatedBy: "\n")
    
    // Pular as duas primeiras linhas
    let startLine = min(2, csvLines.count)
    
    // Inicializar o contador para IDs
    var idCounter = 1
    
    for i in startLine..<csvLines.count {
        let line = csvLines[i].trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Substituir vírgula por ponto em latitude e longitude
        let sanitizedLine = line.replacingOccurrences(of: ",", with: ".")
        let columns = sanitizedLine.components(separatedBy: ";")
        
        // Verifique o número de colunas e remova espaços extras
        if columns.count > 10 {
            let equipamento = columns[0].trimmingCharacters(in: .whitespacesAndNewlines)
            let nome = columns[1].trimmingCharacters(in: .whitespacesAndNewlines)
            let cep = columns[2].trimmingCharacters(in: .whitespacesAndNewlines)
            let latitudeString = columns[3].trimmingCharacters(in: .whitespacesAndNewlines)
            let longitudeString = columns[4].trimmingCharacters(in: .whitespacesAndNewlines)
            let logradouro = columns[5].trimmingCharacters(in: .whitespacesAndNewlines)
            let tipoLocalidade = columns[6].trimmingCharacters(in: .whitespacesAndNewlines)
            let bairro = columns[7].trimmingCharacters(in: .whitespacesAndNewlines)
            let subprefeitura = columns[8].trimmingCharacters(in: .whitespacesAndNewlines)
            let regiao = columns[9].trimmingCharacters(in: .whitespacesAndNewlines)
            let pontosDeAcesso = columns[10].trimmingCharacters(in: .whitespacesAndNewlines)
            
            if let latitude = Double(latitudeString), let longitude = Double(longitudeString) {
                csvData.append(CSVRow(
                    id: idCounter,
                    equipamento: equipamento,
                    nome: nome,
                    cep: cep,
                    latitude: latitude,
                    longitude: longitude,
                    logradouro: logradouro,
                    tipoLocalidade: tipoLocalidade,
                    bairro: bairro,
                    subprefeitura: subprefeitura,
                    regiao: regiao,
                    pontosDeAcesso: pontosDeAcesso
                ))
                
                idCounter += 1
            } else {
                print("Dados de latitude e longitude inválidos: \(latitudeString), \(longitudeString)")
            }
        } else {
        }
    }
}

func printCSVData() {
    if csvData.isEmpty {
        print("Nenhum dado encontrado.")
    } else {
        for row in csvData {
            print("Id: \(row.id), Equipamento: \(row.equipamento), Nome: \(row.nome), CEP: \(row.cep), Latitude: \(row.latitude), Longitude: \(row.longitude), Logradouro: \(row.logradouro), Tipo de Localidade: \(row.tipoLocalidade), Bairro: \(row.bairro), Região: \(row.regiao)\n")
        }
    }
}

// Chama a função para buscar e processar o CSV
fetchAndProcessCSV()



// Usar os dados fora da função
// Por exemplo, para adicionar ao mapa:
// map.addAnnotations(csvData.map { createAnnotation(for: $0) })
