import XCTest
import GRDB

private struct Reader : RowConvertible, MutablePersistable {
    var id: Int64?
    let name: String
    let age: Int?
    
    static func fromRow(row: Row) -> Reader {
        return Reader(
            id: row.value(named: "id"),
            name: row.value(named: "name"),
            age: row.value(named: "age"))
    }
    
    static func databaseTableName() -> String {
        return "readers"
    }
    
    var persistentDictionary: [String: DatabaseValueConvertible?] {
        return ["id": id, "name": name, "age": age]
    }
    
    mutating func didInsertWithRowID(rowID: Int64, forColumn column: String?) {
        id = rowID
    }
}

private struct AltReader : RowConvertible {
    var id: Int64?
    let name: String
    let age: Int?
    
    static func fromRow(row: Row) -> AltReader {
        return AltReader(
            id: row.value(named: "id"),
            name: row.value(named: "name"),
            age: row.value(named: "age"))
    }
}


class RowConvertibleFetchRequestTests: GRDBTestCase {
    
    override func setUp() {
        super.setUp()
        
        var migrator = DatabaseMigrator()
        migrator.registerMigration("createReaders") { db in
            try db.execute(
                "CREATE TABLE readers (" +
                    "id INTEGER PRIMARY KEY, " +
                    "name TEXT NOT NULL, " +
                    "age INT" +
                ")")
        }
        try! migrator.migrate(dbQueue)
    }
    
    
    // MARK: - Fetch RowConvertible
    
    func testAll() {
        assertNoError {
            try dbQueue.inDatabase { db in
                var arthur = Reader(id: nil, name: "Arthur", age: 42)
                try arthur.insert(db)
                var barbara = Reader(id: nil, name: "Barbara", age: 36)
                try barbara.insert(db)
                
                let request = Reader.all()
                
                do {
                    let readers = request.fetchAll(db)
                    XCTAssertEqual(self.lastSQLQuery, "SELECT * FROM \"readers\"")
                    XCTAssertEqual(readers.count, 2)
                    XCTAssertEqual(readers[0].id!, arthur.id!)
                    XCTAssertEqual(readers[0].name, arthur.name)
                    XCTAssertEqual(readers[0].age, arthur.age)
                    XCTAssertEqual(readers[1].id!, barbara.id!)
                    XCTAssertEqual(readers[1].name, barbara.name)
                    XCTAssertEqual(readers[1].age, barbara.age)
                }
                
                do {
                    let reader = request.fetchOne(db)!
                    XCTAssertEqual(self.lastSQLQuery, "SELECT * FROM \"readers\"")
                    XCTAssertEqual(reader.id!, arthur.id!)
                    XCTAssertEqual(reader.name, arthur.name)
                    XCTAssertEqual(reader.age, arthur.age)
                }
                
                do {
                    let names = request.fetch(db).map { $0.name }
                    XCTAssertEqual(self.lastSQLQuery, "SELECT * FROM \"readers\"")
                    XCTAssertEqual(names, [arthur.name, barbara.name])
                }
            }
        }
    }
    
    func testFetch() {
        assertNoError {
            try dbQueue.inDatabase { db in
                var arthur = Reader(id: nil, name: "Arthur", age: 42)
                try arthur.insert(db)
                var barbara = Reader(id: nil, name: "Barbara", age: 36)
                try barbara.insert(db)
                
                do {
                    let readers = Reader.fetchAll(db)
                    XCTAssertEqual(self.lastSQLQuery, "SELECT * FROM \"readers\"")
                    XCTAssertEqual(readers.count, 2)
                    XCTAssertEqual(readers[0].id!, arthur.id!)
                    XCTAssertEqual(readers[0].name, arthur.name)
                    XCTAssertEqual(readers[0].age, arthur.age)
                    XCTAssertEqual(readers[1].id!, barbara.id!)
                    XCTAssertEqual(readers[1].name, barbara.name)
                    XCTAssertEqual(readers[1].age, barbara.age)
                }
                
                do {
                    let reader = Reader.fetchOne(db)!
                    XCTAssertEqual(self.lastSQLQuery, "SELECT * FROM \"readers\"")
                    XCTAssertEqual(reader.id!, arthur.id!)
                    XCTAssertEqual(reader.name, arthur.name)
                    XCTAssertEqual(reader.age, arthur.age)
                }
                
                do {
                    let names = Reader.fetch(db).map { $0.name }
                    XCTAssertEqual(self.lastSQLQuery, "SELECT * FROM \"readers\"")
                    XCTAssertEqual(names, [arthur.name, barbara.name])
                }
            }
        }
    }
    
    func testAlternativeFetch() {
        assertNoError {
            try dbQueue.inDatabase { db in
                var arthur = Reader(id: nil, name: "Arthur", age: 42)
                try arthur.insert(db)
                var barbara = Reader(id: nil, name: "Barbara", age: 36)
                try barbara.insert(db)
                
                let request = Reader.all()
                
                do {
                    let readers = AltReader.fetchAll(db, request)
                    XCTAssertEqual(self.lastSQLQuery, "SELECT * FROM \"readers\"")
                    XCTAssertEqual(readers.count, 2)
                    XCTAssertEqual(readers[0].id!, arthur.id!)
                    XCTAssertEqual(readers[0].name, arthur.name)
                    XCTAssertEqual(readers[0].age, arthur.age)
                    XCTAssertEqual(readers[1].id!, barbara.id!)
                    XCTAssertEqual(readers[1].name, barbara.name)
                    XCTAssertEqual(readers[1].age, barbara.age)
                }
                
                do {
                    let reader = AltReader.fetchOne(db, request)!
                    XCTAssertEqual(self.lastSQLQuery, "SELECT * FROM \"readers\"")
                    XCTAssertEqual(reader.id!, arthur.id!)
                    XCTAssertEqual(reader.name, arthur.name)
                    XCTAssertEqual(reader.age, arthur.age)
                }
                
                do {
                    let names = AltReader.fetch(db, request).map { $0.name }
                    XCTAssertEqual(self.lastSQLQuery, "SELECT * FROM \"readers\"")
                    XCTAssertEqual(names, [arthur.name, barbara.name])
                }
            }
        }
    }
}
