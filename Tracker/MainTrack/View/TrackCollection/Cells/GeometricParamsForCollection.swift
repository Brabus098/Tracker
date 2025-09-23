//  GeometricParamsForCollection.swift

import UIKit

struct GeometricParams {
    let cellCount: Int
    let leftInsert: CGFloat
    let rightInsert: CGFloat
    let cellSpacing: GLfloat
    let paddingWidth: CGFloat
    
    init(cellCount: Int, leftInsert: CGFloat, rightInsert: CGFloat, cellSpacing: GLfloat) {
        self.cellCount = cellCount
        self.leftInsert = leftInsert
        self.rightInsert = rightInsert
        self.cellSpacing = cellSpacing
        self.paddingWidth = leftInsert + rightInsert + CGFloat(cellCount - 1) * CGFloat(cellSpacing)
    }
}
