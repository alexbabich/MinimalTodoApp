//
//  ContentView.swift
//  MinimalTodoApp
//
//  Created by alex-babich on 19.06.2020.
//  Copyright © 2020 alex-babich. All rights reserved.
//

import SwiftUI
import CoreData

struct ContentView: View {
    var body: some View {
        
        Home()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}


struct Home: View {
    
    @State var todayTasks : [String] = []
    
    var body: some View {
        NavigationView {
            VStack {
                
                HomeCalenderView()
                    .padding(.vertical, 25)
                
                VStack {
                    
                    HStack {
                        Text("TASKS")
                            .fontWeight(.bold)
                        
                        Spacer()
                        
                        NavigationLink(destination: AddPage()) {
                            
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 22, height: 22)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.leading)
                    
                    Divider()
                        .background(Color.black.opacity(0.8))
                }
                
                GeometryReader {_ in
                    
                    if !self.todayTasks.isEmpty {
                        
                        ScrollView(.vertical, showsIndicators: false) {
                            
                            VStack {
                                
                                ForEach(0..<self.todayTasks.count, id: \.self) { i in
                                    
                                    HStack {
                                        
                                        Button(action: {
                                            self.DeleteTask(task: i)
                                        }) {
                                            Image(systemName: "checkmark.circle")
                                            .resizable()
                                            .frame(width: 22, height: 22)
                                            .foregroundColor(.green)
                                            .padding(.trailing, 10)
                                        }
                                        
                                        Text(self.todayTasks[i])
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                    .padding(.top, 20)
                                }
                            }
                        }
                    }
                    
                }
            }
            .navigationBarTitle("Todo", displayMode: .large)
            .background(Color.black.opacity(0.06).edgesIgnoringSafeArea(.bottom))
            .onAppear {
                self.getTasks()
                self.DeleteOldTasks()
            }
        }
    }

    // reading data
    func getTasks() {
        let app = UIApplication.shared.delegate as! AppDelegate
        
        // creating context from app delegate
        let context = app.persistentContainer.viewContext
        
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
        
        do {
            
            // going to fetch all data...
            let result = try context.fetch(req)
            
            self.todayTasks.removeAll()
            
            for i in result as! [NSManagedObject] {
                
                let task = i.value(forKey: "task") as! String
                let date = i.value(forKey: "date") as! Date
                
                
                // comparing date and displaying only today tasks...
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-YYYY"
                
                if formatter.string(from: date) == formatter.string(from: Date()) {
//                    append to array
                    self.todayTasks.append(task)
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
    
    func DeleteOldTasks() {
        
//        deleting all old data
        
        let app = UIApplication.shared.delegate as! AppDelegate
        
        // creating context from app delegate
        let context = app.persistentContainer.viewContext
        
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
        
        do {
            
            // going to fetch all data...
            let result = try context.fetch(req)
            
            for i in result as! [NSManagedObject] {
                
                let date = i.value(forKey: "date") as! Date
                
                
                // comparing date and displaying only today tasks...
                let formatter = DateFormatter()
                formatter.dateFormat = "dd-MM-YYYY"
                
//                    quering old data ...
                
                if formatter.string(from: date) < formatter.string(from: Date()) {
                    context.delete(i)
                    try context.save()
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }

//    separate deletion ...
    func DeleteTask(task: Int) {
            
    //        deleting all old data
            
        let app = UIApplication.shared.delegate as! AppDelegate
        
        // creating context from app delegate
        let context = app.persistentContainer.viewContext
        
        let req = NSFetchRequest<NSFetchRequestResult>(entityName: "Todo")
        
        do {
            
            // going to fetch all data...
            let result = try context.fetch(req)
            
            for i in result as! [NSManagedObject] {
                
                let currenttask = i.value(forKey: "task") as! String

                if self.todayTasks[task] == currenttask {
                    context.delete(i)
                    try context.save()
                    
                    self.todayTasks.remove(at: task)
                    
                    return
                }
            }
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

struct AddPage: View {
    
    // for inserting date into codeData...
    @State var date = Date()
    @State var task = ""
    @Environment(\.presentationMode) var present
    // moving views up when keyboard appeaars...
    @State var keyboardHeight : CGFloat = 0
    
    var body: some View {
        
        VStack {
            Spacer(minLength: 0)
            
//            going to shrink this view when keyboard appears for phones like iphone...
            CalenderView(date: self.$date)
                .scaleEffect((UIScreen.main.bounds.height < 750 && self.keyboardHeight != 0) ? 0.65 : 1)
//                since view is shrinked we're reducing height...
                .padding(.vertical, (UIScreen.main.bounds.height < 750 && self.keyboardHeight != 0) ? -60 : 0)
            
            Spacer(minLength: 0)
            
            Divider()
                .background(Color.black.opacity(0.8))
            
            TextField("Type here", text: self.$task)
                .padding(.horizontal)
                .padding(.bottom)
        }
        .padding(.bottom, self.keyboardHeight)
        .navigationBarTitle("Add new task", displayMode: .large)
//            because top is navigation bar ...
        .background(Color.black.opacity(0.06).edgesIgnoringSafeArea(.bottom))
        .navigationBarItems(trailing:
            Button(action: {
                self.saveTask()
            }, label: {
                Text("Done")
                    .fontWeight(.bold)
            })
            .disabled(self.task == "" ? true : false)
        )
        
        .onAppear {
                
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidShowNotification, object: nil, queue: .main) { (notification) in
                
                let frame = notification.userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
                
                let height = frame.cgRectValue.height
                
                withAnimation {
//                    reducing bottom safe area height...
                    
                    self.keyboardHeight = height - (UIApplication.shared.windows.first?.safeAreaInsets.bottom)!
                }
            }
            
            NotificationCenter.default.addObserver(forName: UIResponder.keyboardDidHideNotification, object: nil, queue: .main) { (notification) in
                
                withAnimation {
                    self.keyboardHeight = 0
                }
            }
        }
    }
    
    func saveTask() {
        
        let app = UIApplication.shared.delegate as! AppDelegate
        
        let context = app.persistentContainer.viewContext
        
        let entity = NSEntityDescription.insertNewObject(forEntityName: "Todo", into: context)
        
        entity.setValue(self.task, forKey: "task")
        entity.setValue(self.date, forKey: "date")
        
        do {
            try context.save()
            
            self.present.wrappedValue.dismiss()
        }
        catch {
            print(error.localizedDescription)
        }
    }
}

struct HomeCalenderView : View {
    
    @State var date = Date()
    @State var data : DateType!
    
    var body: some View{
        
        VStack{
            
            if self.data != nil{
                
                ZStack{
                    
                    VStack(spacing: 15){
                        
                        ZStack{
                            
                            HStack{
                                
                                Spacer()
                                
                                Text(self.data.Month)
                                    .font(.title)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.vertical)
    
                        }
                        .background(Color.red)
                        
                        Text(self.data.Date)
                            .font(.system(size: 65))
                            .fontWeight(.bold)
                        
                        Text(self.data.Day)
                            .font(.title)
                        
                        Divider()
                        
                        ZStack{
                            
                            Text(self.data.Year)
                                .font(.title)
                        }

                    }
                    .padding(.bottom, 12)

                }
                .frame(width: UIScreen.main.bounds.width / 1.5)
                .background(Color.white)
                .cornerRadius(15)
            }
        }
        .onAppear {
            self.date = Date()
            self.UpdateDate()
        }
        
    }
    
    func UpdateDate(){
        
        let current = Calendar.current
        
        let date = current.component(.day, from: self.date)
        let monthNO = current.component(.month, from: self.date)
        let month = current.monthSymbols[monthNO - 1]
        let year = current.component(.year, from: self.date)
        let weekno = current.component(.weekday, from: self.date)
        let day = current.weekdaySymbols[weekno - 1]
        
        self.data = DateType(Day: day, Date: "\(date)", Year: "\(year)", Month: month)
    }
}

struct CalenderView : View {
    
    @Binding var date : Date
    @State var data : DateType!
    @State var expand = false
    @State var year = false
    
    var body: some View{
        
        VStack{
            
            if self.data != nil{
                
                ZStack{
                    
                    VStack(spacing: 15){
                        
                        ZStack{
                            
                            HStack{
                                
                                Spacer()
                                
                                Text(self.data.Month)
                                    .font(.title)
                                    .foregroundColor(.white)
                                
                                Spacer()
                            }
                            .padding(.vertical)
                            
                            HStack{
                                
                                Button(action: {
                                    
                                    self.date = Calendar.current.date(byAdding: .month, value: -1, to: self.date)!
                                    
                                    self.UpdateDate()
                                    
                                }) {
                                    
                                    Image(systemName: "arrow.left")
                                        
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    
                                    self.date = Calendar.current.date(byAdding: .month, value: 1, to: self.date)!
                                    
                                    self.UpdateDate()
                                    
                                }) {
                                    
                                    Image(systemName: "arrow.right")
                                        
                                }
                                
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 30)
                            
                        }
                        .background(Color.red)
                        
                        Text(self.data.Date)
                            .font(.system(size: 65))
                            .fontWeight(.bold)
                        
                        Text(self.data.Day)
                            .font(.title)
                        
                        Divider()
                        
                        ZStack{
                            
                            Text(self.data.Year)
                                .font(.title)
                            
                            HStack{
                                
                                Spacer()
                                
                                Button(action: {
                                    
                                    withAnimation(.default){
                                        
                                        self.expand.toggle()
                                    }
                                    
                                }) {
                                 
                                    Image(systemName: "chevron.right")
                                    .renderingMode(.original)
                                    .resizable()
                                    .frame(width: 10, height: 16)
                                    .rotationEffect(.init(degrees: self.expand ? 270 : 90))
                                }
                                .padding(.trailing, 30)
                            }
                        }
                        
                        if self.expand{
                            
                            Toggle(isOn: self.$year) {
                                
                                Text("Year")
                                    .font(.title)
                                    
                            }
                            .padding(.trailing, 15)
                            .padding(.leading, 25)
                        }
                        
                    }
                    .padding(.bottom,self.expand ? 15 : 12)
                    
                    HStack{
                        
                        Button(action: {
                            
                            self.date = Calendar.current.date(byAdding: self.year ? .year : .day, value: -1, to: self.date)!
                            
                            self.UpdateDate()
                            
                        }) {
                            
                            Image(systemName: "arrow.left")
                                .foregroundColor(.black)
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            
                            self.date = Calendar.current.date(byAdding: self.year ? .year : .day, value: 1, to: self.date)!
                            
                            self.UpdateDate()
                            
                        }) {
                            
                            Image(systemName: "arrow.right")
                                .foregroundColor(.black)
                        }
                        
                    }
                    .padding(.horizontal, 30)
                }
                .frame(width: UIScreen.main.bounds.width / 1.5)
                .background(Color.white)
                .cornerRadius(15)
            }
        }
        .onAppear {
            
            // automatic update for date change...
            self.date = Date()
            self.UpdateDate()
        }
        
    }
    
    func UpdateDate(){
        
        let current = Calendar.current
        
        let date = current.component(.day, from: self.date)
        let monthNO = current.component(.month, from: self.date)
        let month = current.monthSymbols[monthNO - 1]
        let year = current.component(.year, from: self.date)
        let weekno = current.component(.weekday, from: self.date)
        let day = current.weekdaySymbols[weekno - 1]
        
        self.data = DateType(Day: day, Date: "\(date)", Year: "\(year)", Month: month)
    }
}

struct DateType {
    
    var Day : String
    var Date : String
    var Year : String
    var Month : String
}
