using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace AiferuFramework.ArtBrushTool
{
    /// <summary>
    /// 美术刷草工具主类,用于调用美术刷草工具的功能,基础路径保存在这里
    /// </summary>
    public class ArtBrushToolMain 
    {
        private readonly static string toolsPath;
        private static string toolsDataSavePath;

        public static string ToolsPath {
            get {
                return null;
            }
        }
        public static string ToolsDataSavePath { get => toolsDataSavePath; set => toolsDataSavePath = value; }
    }
}

