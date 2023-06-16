//
//  UIImage+.swift
//  MyMusicApp
//
//  Created by 지희의 MAC on 2023/06/16.
//

import UIKit

extension UIImage {
    
    /// 불러온 이미지 사이즈 변경
    func resized(to size: CGSize) -> UIImage? {
        // 비트맵 생성
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        // 비트맵 그래픽 배경에 이미지 다시 그리기
        self.draw(in: CGRect(origin: CGPoint.zero, size: size))
        // 현재 비트맵 그래픽 배경에서 이미지 가져오기
        guard let resizedImage = UIGraphicsGetImageFromCurrentImageContext() else {
            return nil
        }
        // 비트맵 환경 제거
        UIGraphicsEndImageContext()
        // 크기가 조정된 이미지 반환
        return resizedImage
    }
    
    func resized(to size: CGSize, tintColor: UIColor) -> UIImage {
        return UIGraphicsImageRenderer(size: size).image { _ in
            // 적용할 tint 색상 설정
            tintColor.setFill()
            // 렌더링 모드 변경 후 이미지 그리기
            withRenderingMode(.alwaysTemplate).draw(in: CGRect(origin: .zero, size: size))
        }
    }
}
