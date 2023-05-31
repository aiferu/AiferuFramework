//
//  InputMaterialTextureConfig.cs
//  AiferuFramework
//
//  Created by Aiferu on 2023/2/7.
//
//
#if UNITY_EDITOR
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
namespace AiferuFramework.ArtBrushTool
{
    /// <summary>
    /// �洢����ˢ�ݹ��ߵĳ־û�����
    /// </summary>
    [CreateAssetMenu(fileName = "ArtBrushToolData", menuName = "cs",order = 7)]
    public class ArtBrushToolData : ScriptableObject
    {
        /// <summary>
        /// ����������Ӷ�������
        /// </summary>
        public static int PlantCount = 6;
        /// <summary>
        /// ��ˢ��С
        /// </summary>
        public float BrushSize;
        /// <summary>
        /// �ݶ��������С��Χ���ֵ
        /// </summary>
        public float ScaleRandomMax;
        /// <summary>
        /// �ݶ��������С��Χ��Сֵ
        /// </summary>
        public float ScaleRandomMin;
        /// <summary>
        /// ���ܶ�
        /// </summary>
        public int Density;
        /// <summary>
        /// Plant��������
        /// </summary>
        public GameObject[] Plants = new GameObject[PlantCount];

        
    }
}
#endif