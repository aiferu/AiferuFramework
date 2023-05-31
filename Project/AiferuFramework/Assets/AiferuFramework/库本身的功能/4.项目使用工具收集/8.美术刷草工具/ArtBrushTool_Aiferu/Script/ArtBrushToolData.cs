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
    /// 存储美术刷草工具的持久化数据
    /// </summary>
    [CreateAssetMenu(fileName = "ArtBrushToolData", menuName = "cs",order = 7)]
    public class ArtBrushToolData : ScriptableObject
    {
        //需要存储的数据
        //1.BrushSize 画刷大小
        public int BrushSize;
        //2.ScaleRandom 草对象随机大小范围
        public float ScaleRandomMax;
        public float ScaleRandomMin;
        //3.Density 草密度
        public int Density;
        //4.Plant对象数组
        public GameObject[] Plants;
        //5.工具最大可添加对象个数
        public int PlantCount;
    }
}
#endif