using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

namespace AiferuFramework.ArtBrushTool
{
    /// <summary>
    /// ����ˢ�ݹ�������,���ڵ�������ˢ�ݹ��ߵĹ���,����·������������
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

