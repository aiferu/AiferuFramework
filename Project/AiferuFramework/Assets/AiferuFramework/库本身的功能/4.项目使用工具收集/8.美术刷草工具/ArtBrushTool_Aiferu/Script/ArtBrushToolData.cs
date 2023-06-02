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
        /// <summary>
        /// 工具最大可添加对象数量
        /// </summary>
        public static int PlantCount = 6;
        /// <summary>
        /// 画刷大小
        /// </summary>
        public float BrushSize;
        /// <summary>
        /// 草对象随机大小范围最大值
        /// </summary>
        public float ScaleRandomMax;
        /// <summary>
        /// 草对象随机大小范围最小值
        /// </summary>
        public float ScaleRandomMin;
        /// <summary>
        /// 草密度
        /// </summary>
        public int Density;
        /// <summary>
        /// Plant对象数组
        /// </summary>
        public GameObject[] Plants = new GameObject[PlantCount];
        /// <summary>
        /// SelectionGrid组件中选中对象的序号,0开始
        /// </summary>
        public int PlantSelect;
        /// <summary>
        /// 笔刷是否是叠加模式(叠加与减去切换)
        /// </summary>
        public bool BrushIsAddMode = true;

        /// <summary>
        /// 是否需要碰撞体
        /// </summary>
        public bool NeedCollider = true;

        public GameObject MapDataObject;
    }
}
#endif